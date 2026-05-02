---
Date: 2026-05-02 18:49:00
Author: christphralden
Title: 005-infra
---

## Infrastructure Overview

Two environments only: **local** (Docker Compose dev stack) and **production** (EC2 on AWS).

```
EC2 t3.micro (Ubuntu)
├── Nginx (host process)     port 80/443 — TLS termination, static files, reverse proxy
├── web-server container     Express app on 127.0.0.1:3000 (not exposed to internet)
└── postgres container       Postgres on 127.0.0.1:5432 (not exposed to internet)
```

Nginx runs directly on the host, not in Docker. It proxies `/api/*` and `/health` to the Express container and serves the React SPA from `/var/www/magic-nugger/web-app`.

---

## Environment Files

| File                      | Purpose                                                                                     |
| ------------------------- | ------------------------------------------------------------------------------------------- |
| `.env.local`              | Local development. Loaded by `npm run db:migrate` and `docker-compose.dev.yml`.             |
| `.env.production`         | Production. Written by GitHub Actions on every deploy from GitHub Secrets. Never committed. |
| `.env.local.example`      | Template for local setup — copy to `.env.local` and fill in values.                         |
| `.env.production.example` | Reference for what production expects.                                                      |

**Key distinctions between environments:**

- `ENVIRONMENT=local` in `.env.local` disables graceful shutdown signal handlers in `src/index.ts`.
- `DATABASE_URL` is not set in `.env.production` — `docker-compose.yml` constructs it from `APP_USER`, `APP_USER_PASSWORD`, and `POSTGRES_DB` at runtime via the `environment:` block.
- `POSTGRES_HOST=localhost` locally, `POSTGRES_HOST=magic-nugger-postgres` (the Docker network alias) in production.

**Generating `SESSION_SECRET`:**

```bash
openssl rand -base64 32
```

---

## Docker Compose

Two compose files: `docker-compose.yml` (production base) and `docker-compose.dev.yml` (dev overrides that extend the base).

### Production: `docker-compose.yml`

Defines two services: `magic-nugger-postgres` and `magic-nugger-web-server`.

**Postgres service:**

```yaml
image: postgres:16-alpine
shm_size: 256mb
command: >
  postgres
  -c log_min_duration_statement=1000
  -c max_connections=200
```

- `log_min_duration_statement=1000` — logs any query taking over 1 second. Tune this down during debugging.
- `max_connections=200` — sized for the t3.micro. The app pool (`DB_POOL_MAX`) defaults to 20, so there is headroom.
- `shm_size: 256mb` — prevents shared memory exhaustion under moderate load on Alpine.
- Postgres port is bound to `127.0.0.1:5432` — not reachable from outside the EC2.
- Init scripts from `./db/init/` run once on first container startup (when the named volume is empty).
- Data persists in the named volume `magic-nugger-postgres-data`.

**Health check:** `pg_isready -U $APP_USER -d $POSTGRES_DB` every 5s, 5 retries. The web-server container will not start until this passes (`depends_on: condition: service_healthy`).

**Web-server service:**

- Binds to `127.0.0.1:3000` — only Nginx can reach it.
- `restart: unless-stopped` — restarts on crash, but not when manually stopped.
- Logging: `json-file` driver, capped at 10 MB per file, 3 files max (30 MB total). Prevents disk fill on t3.micro.
- Health check polls `GET /health` which checks DB connectivity (`SELECT 1`). 3 retries, 10s interval, 10s start_period.

**Run in production (manual):**

```bash
cd /magic-nugger
docker compose --env-file .env.production up -d
```

**Stop:**

```bash
docker compose --env-file .env.production down
```

**Rebuild server image only (after code changes):**

```bash
docker compose --env-file .env.production build magic-nugger-web-server
docker compose --env-file .env.production up -d magic-nugger-web-server
```

**View live logs:**

```bash
docker compose logs -f magic-nugger-web-server
docker compose logs -f magic-nugger-postgres
```

### Local Development: `docker-compose.dev.yml`

Extends the production base and overrides the web-server for hot-reload dev:

```bash
docker compose -f docker-compose.dev.yml --env-file .env.local up
```

Key overrides applied:

- `build.target: dev` — uses the `dev` stage of the Dockerfile (no production build, no entrypoint).
- Source mount: `./web-server:/magic-nugger` + anonymous volume to protect `node_modules`.
- `command: npm run dev` — runs ts-node-dev with hot reload.
- `NODE_ENV=development`, `ENVIRONMENT=local`.

The Vite dev server (`npm run dev` inside `web-app/`) runs **outside Docker**, directly on the host at `localhost:5173`. It talks to the containerized Express server at `localhost:3000`.

**First-time local setup:**

```bash
cp .env.local.example .env.local
# fill in POSTGRES_USER, POSTGRES_PASSWORD, APP_USER, APP_USER_PASSWORD, APP_RO_USER, APP_RO_PASSWORD, SESSION_SECRET

docker compose -f docker-compose.dev.yml --env-file .env.local up -d

# Migrations run automatically inside the server container on dev startup.
# To run manually against the local DB from the host:
npm run db:migrate
```

---

## Dockerfile (web-server/Dockerfile)

Four-stage multi-stage build:

```
base        node:20-alpine — installs all deps (npm ci)
  └── dev         exposes /magic-nugger, CMD ["npm", "run", "dev"]
  └── builder     runs npm run build → produces dist/
        └── production  copies dist/ + db/ + package*.json, npm ci --omit=dev, adds dumb-init
```

**Production image specifics:**

- `dumb-init` handles PID 1 signal forwarding. Without it, `SIGTERM` sent by Docker does not reach the Node process — graceful shutdown never runs.
- `wget` is installed for the Docker health check (`wget --quiet --tries=1 --spider http://127.0.0.1:3000/health`).
- Runs as `USER node` (non-root) — required for production security posture.
- `ENTRYPOINT ["dumb-init", "--", "/magic-nugger/entrypoint.sh"]` + `CMD ["node", "dist/index.js"]` — entrypoint runs migrations then execs the CMD.
- `db/` directory is copied into the production image so `entrypoint.sh` can call `npm run db:migrate` without a host mount.

**entrypoint.sh boot sequence:**

```
1. npm run db:migrate    (runner.mjs up — idempotent, skips applied patches)
2. exec node dist/index.js
```

If any migration fails, the entrypoint exits non-zero → Docker marks the container unhealthy → `restart: unless-stopped` retries. This prevents a broken schema from silently serving requests.

---

## Nginx (nginx/frontend.nginx.conf)

Nginx runs on the EC2 host (not in Docker). Config is deployed by GitHub Actions via `rsync` from `nginx/frontend.nginx.conf` to `/etc/nginx/nginx.conf` on the EC2 (or placed at `/etc/nginx/conf.d/magic-nugger.conf` depending on your distro layout).

### Traffic flow

```
Client
  → :80  HTTP   → ACME challenge passthrough OR 301 → HTTPS
  → :443 HTTPS  → /api/v1/auth/*  (rate-limited: 10 rpm, burst 5)
                → /api/*          (rate-limited: 60 rps, burst 30)
                → /health         (no rate limit, no logging)
                → /*.js|.css|...  (static assets, 1y cache, immutable)
                → /*.wasm|.data   (Unity WebGL artifacts, 1y cache)
                → /*              (SPA fallback: try_files → index.html)
```

### Rate limiting

Defined at the `http` block level, keyed by `$binary_remote_addr` (client IP):

| Zone   | Limit  | Burst | nodelay | Applied to      |
| ------ | ------ | ----- | ------- | --------------- |
| `api`  | 60 r/s | 30    | yes     | `/api/`         |
| `auth` | 10 r/m | 5     | yes     | `/api/v1/auth/` |

`nodelay` means burst requests are served immediately (not queued) but count against the burst budget. Once burst is exhausted, requests get 429.

The Express layer also enforces `RPM_LIMIT=3000` (default) as a secondary rate limit. Nginx is the outer wall; Express is the inner.

### TLS and HSTS

Certbot (Let's Encrypt) manages the cert. On first EC2 setup:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

Certbot patches the server block in-place with `ssl_certificate` and `ssl_certificate_key` paths. Auto-renewal runs via the certbot systemd timer.

HSTS is set to `max-age=63072000; includeSubDomains; preload` (2 years). Do not enable `preload` until you are certain the domain and all subdomains will permanently serve HTTPS.

### Security headers

| Header                    | Value                             | Purpose                              |
| ------------------------- | --------------------------------- | ------------------------------------ |
| `X-Frame-Options`         | `SAMEORIGIN`                      | Prevents clickjacking                |
| `X-Content-Type-Options`  | `nosniff`                         | Prevents MIME sniffing               |
| `Referrer-Policy`         | `strict-origin-when-cross-origin` | Limits referrer leakage              |
| `Permissions-Policy`      | geolocation/mic/camera off        | Locks down browser APIs              |
| `Content-Security-Policy` | see config                        | No `unsafe-eval`, no `unsafe-inline` |

CSP note: `'unsafe-eval'` is intentionally absent. If a Unity WebGL build requires it (asm.js eval), add it back only to `script-src` and only for the WebGL asset path.

### Caching strategy

- API responses: `Cache-Control: no-store` — never cached anywhere.
- HTML: `no-store` — always fetched fresh so SPA deploys take effect immediately.
- Static assets (JS/CSS/fonts/images): `public, immutable, max-age=1y` — Vite content-hashes filenames so this is safe.
- Unity WebGL artifacts (`.wasm`, `.data`, `.unityweb`): same 1y immutable rule.

### Upstream keepalives

```nginx
upstream api {
    server 127.0.0.1:3000;
    keepalive 64;
}
```

`keepalive 64` keeps up to 64 idle connections to Express open, avoiding TCP handshake overhead on every proxied request. The Express server's `keepAliveTimeout` (65s) is set 1s above Nginx's `keepalive_timeout` (65s) to prevent race conditions where Nginx reuses a connection that Express has already closed.

---

## Database

### User model

Three Postgres roles are created at first startup via `db/init/001_users.sh`:

| Role            | Privileges                                                       | Used by                                 |
| --------------- | ---------------------------------------------------------------- | --------------------------------------- |
| `POSTGRES_USER` | Superuser                                                        | Migrations runner, init scripts only    |
| `APP_USER`      | SELECT, INSERT, UPDATE, DELETE on all tables; USAGE on sequences | Express app (`DATABASE_URL`)            |
| `APP_RO_USER`   | SELECT only on all tables                                        | Read-only queries, analytics, debugging |

`APP_USER` and `APP_RO_USER` are created by the init script with `ALTER DEFAULT PRIVILEGES`, meaning new tables automatically inherit the correct grants without manual intervention after each migration.

The init script only runs when the Postgres data volume is empty (first boot). It is not re-executed on restarts.

### Migration system

Source of truth for schema state is the `_v.patches` table inside Postgres. The runner at `db/runner.mjs` is the only way to apply or roll back schema changes.

**`_v` schema objects:**

```sql
_v.patches                         -- tracks applied patches
_v.try_register_patch(name, deps, description) RETURNS boolean
_v.unregister_patch(name)
```

`try_register_patch` is idempotent: returns `false` if already applied, raises if a declared dependency is not yet applied. This enforces correct ordering even if patches are applied out of order.

**Runner behaviour:**

- `up`: reads `db/migrations/apply/` sorted alphabetically, skips any patch already in `_v.patches`, applies the rest in order. Each file is run as a single `client.query(sql)` call — the SQL must manage its own transaction if needed.
- `down`: queries `_v.patches ORDER BY applied_at DESC LIMIT 1`, reads the matching file from `db/migrations/rollback/`, executes it. One patch at a time.

The runner connects using `POSTGRES_USER` (superuser), not `APP_USER`, because migrations may need to create schemas, functions, and grant privileges.

**Running migrations:**

```bash
# Apply all pending patches (local)
npm run db:migrate

# Rollback the most recently applied patch (local)
npm run db:rollback
```

Both commands load `.env.local` via `--env-file=.env.local`. In production, migrations run automatically inside the container via `entrypoint.sh` on every deploy.

**Creating a new migration:**

1. Choose a timestamp prefix: `yyyymmddHHmm` (e.g. `202605021430`). Both apply and rollback files must share the same prefix.

2. Create `db/migrations/apply/202605021430_description.sql`:

```sql
DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
        '202605021430_description',
        ARRAY['202605020010_create_elo_history'],
        'Human-readable description of what this does'
    ) INTO patch_registered;

    IF patch_registered THEN
        -- your DDL here
        CREATE INDEX idx_example ON game_sessions (level_id, score DESC);
    END IF;
END $$;
```

3. Create `db/migrations/rollback/202605021430_description.sql`:

```sql
BEGIN;
SELECT _v.unregister_patch('202605021430_description');
DROP INDEX IF EXISTS idx_example;
COMMIT;
```

**Rules:**

- Always declare the direct parent patch in `dependencies`. The runner enforces this at apply time.
- Apply files do not need `BEGIN/COMMIT` unless you want explicit transaction control — wrap DDL in a transaction when the operation must be atomic.
- Rollback files must always `BEGIN/COMMIT`. They call `unregister_patch` first, then undo the DDL.
- Never edit an already-applied patch file. Create a new patch instead.
- Filename sort order = application order. Use zero-padded sequential suffixes within the same minute (e.g. `...0000`, `...0001`) to guarantee ordering.

**Inspecting patch state:**

```bash
# Connect to local DB
psql postgresql://$APP_USER:$APP_USER_PASSWORD@localhost:5432/magic_nugger

# List all applied patches in order
SELECT patch_name, applied_at FROM _v.patches ORDER BY applied_at;
```

---

## CI/CD — GitHub Actions

Workflow file: `.github/workflows/deploy.yml`

**Trigger:** push to `master`, but only executes if the GitHub Actions variable `ENABLE_REMOTE_DEPLOYMENT` is set to `'true'`. This acts as a kill-switch to pause deploys without changing code.

**Concurrency:** `group: deploy-production`, `cancel-in-progress: false` — concurrent deploys queue instead of cancelling each other.

**Deploy steps (composite actions under `.github/actions/`):**

| Step             | Action            | What it does                                                                                        |
| ---------------- | ----------------- | --------------------------------------------------------------------------------------------------- |
| Validate secrets | inline            | Fails fast if `SESSION_SECRET` or `POSTGRES_PASSWORD` are empty                                     |
| Write env        | `write-env`       | SSHes into EC2, writes `/magic-nugger/.env.production` from secrets with `chmod 600`                |
| Pull code        | `pull-code`       | `git clone` on first run; `git fetch && git reset --hard origin/master` on subsequent runs          |
| Deploy frontend  | `deploy-frontend` | `npm ci && npm run build` on EC2, `rsync dist/ → /var/www/magic-nugger/web-app/`, `nginx -s reload` |
| Deploy server    | `deploy-server`   | `docker compose build magic-nugger-web-server && docker compose up -d magic-nugger-web-server`      |
| Health check     | `health-check`    | Polls `http://127.0.0.1:3000/health` up to 30 times (60s). Dumps logs and fails if never healthy.   |
| Cleanup          | `cleanup`         | `docker image prune -f` — removes dangling images to reclaim disk on t3.micro                       |

**GitHub Secrets required:**

| Name                   | Type   | Description                                                      |
| ---------------------- | ------ | ---------------------------------------------------------------- |
| `EC2_HOST`             | secret | Public IP of the EC2 instance                                    |
| `EC2_USERNAME`         | secret | SSH username (typically `ubuntu`)                                |
| `EC2_SSH_KEY`          | secret | Private SSH key for the EC2 instance                             |
| `POSTGRES_USER`        | secret | Postgres superuser name                                          |
| `POSTGRES_PASSWORD`    | secret | Postgres superuser password                                      |
| `POSTGRES_DB`          | secret | Database name (usually `magic_nugger`)                           |
| `APP_USER`             | secret | App DB user name                                                 |
| `APP_USER_PASSWORD`    | secret | App DB user password                                             |
| `APP_RO_USER`          | secret | Read-only DB user name                                           |
| `APP_RO_PASSWORD`      | secret | Read-only DB user password                                       |
| `SESSION_SECRET`       | secret | Express session secret (generate with `openssl rand -base64 32`) |
| `GOOGLE_CLIENT_ID`     | secret | Google OAuth client ID                                           |
| `GOOGLE_CLIENT_SECRET` | secret | Google OAuth client secret                                       |
| `CORS_ORIGIN`          | secret | Allowed CORS origin (e.g. `https://yourdomain.com`)              |

**GitHub Variables (non-sensitive defaults):**

| Name                            | Default                 |
| ------------------------------- | ----------------------- |
| `POSTGRES_HOST`                 | `magic-nugger-postgres` |
| `PORT`                          | `3000`                  |
| `RPM_LIMIT`                     | `3000`                  |
| `DB_POOL_MAX`                   | `20`                    |
| `DB_POOL_IDLE_TIMEOUT_MS`       | `30000`                 |
| `DB_POOL_CONNECTION_TIMEOUT_MS` | `5000`                  |
| `DB_QUERY_TIMEOUT_MS`           | `30000`                 |
| `DB_SSL_MODE`                   | `prefer`                |

---

## EC2 First-Time Setup

```bash
# 1. Install dependencies
sudo apt update && sudo apt install -y docker.io docker-compose-plugin nginx nodejs npm git certbot python3-certbot-nginx

# 2. Add ubuntu user to docker group
sudo usermod -aG docker ubuntu && newgrp docker

# 3. Clone repo
git clone https://github.com/<org>/magic-nugger-app.git /magic-nugger

# 4. Copy nginx config
sudo cp /magic-nugger/nginx/frontend.nginx.conf /etc/nginx/nginx.conf
sudo nginx -t && sudo systemctl reload nginx

# 5. Obtain TLS cert (replace with actual domain)
sudo certbot --nginx -d yourdomain.com

# 6. Start Postgres and let it init (creates DB and runs db/init/ scripts)
cd /magic-nugger
docker compose --env-file .env.production up -d magic-nugger-postgres
# Wait for healthy: docker compose ps

# 7. Start server (migrations run automatically via entrypoint.sh)
docker compose --env-file .env.production up -d magic-nugger-web-server

# 8. Verify
curl http://127.0.0.1:3000/health
```

**EC2 security group rules:**

| Port | Protocol | Source       | Reason                      |
| ---- | -------- | ------------ | --------------------------- |
| 22   | TCP      | your IP only | SSH                         |
| 80   | TCP      | 0.0.0.0/0    | HTTP (ACME + redirect)      |
| 443  | TCP      | 0.0.0.0/0    | HTTPS                       |
| 5432 | TCP      | —            | Blocked — internal only     |
| 3000 | TCP      | —            | Blocked — Nginx-only access |
