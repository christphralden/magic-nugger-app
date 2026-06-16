# Deployment Guide

Single EC2 instance. Nginx on the host handles static files + reverse proxy. SSL via Certbot. All secrets and deploys are managed by the CI/CD pipeline — no manual server configuration after initial setup.

---

## Prerequisites

- AWS account
- Registered domain pointing to your EC2 public IP
- GitHub repository with `master` branch

---

## 1. Provision EC2

Launch an Ubuntu 22.04 LTS `t3.micro` (or larger) with:

| Port | Source    | Purpose |
| ---- | --------- | ------- |
| 22   | Your IP   | SSH     |
| 80   | 0.0.0.0/0 | HTTP    |
| 443  | 0.0.0.0/0 | HTTPS   |

**Storage:** Add a 20GB EBS volume for Postgres data.

---

## 4. SSL (Certbot)

### CI/CD

Change DOMAIN on github variables will reexecute certbot [configure-server](https://github.com/christphralden/magic-nugger-app/blob/master/.github/actions/configure-server/action.yml)

### Manual

Point your DNS A record to the EC2 public IP first, then:

```bash
sudo certbot --nginx -d youractualdomain.com
```

Certbot adds the 443 block, SSL cert paths, HTTP redirect, and HSTS automatically. Verify auto-renewal:

```bash
sudo certbot renew --dry-run
```

Change nginx to your domain

---

## 5. GitHub Secrets and Variables

Go to **GitHub → Settings → Secrets and variables → Actions**.

### Secrets

| Secret                     | Description                                                                                                                                         |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `EC2_HOST`                 | Public IP of your EC2                                                                                                                               |
| `EC2_USERNAME`             | SSH username (`ubuntu` for Ubuntu AMIs)                                                                                                             |
| `EC2_SSH_KEY`              | Private SSH key for the EC2 user                                                                                                                    |
| `POSTGRES_USER`            | Database superuser name                                                                                                                             |
| `POSTGRES_PASSWORD`        | Database superuser password                                                                                                                         |
| `POSTGRES_DB`              | Database name                                                                                                                                       |
| `APP_USER`                 | Database app user (SELECT/INSERT/UPDATE/DELETE)                                                                                                     |
| `APP_USER_PASSWORD`        | Database app user password                                                                                                                          |
| `APP_RO_USER`              | Database read only user (SELECT only)                                                                                                               |
| `APP_RO_PASSWORD`          | Database read only user password                                                                                                                    |
| `PARTMAN_PASSWORD`         | Password for `partman_user` — pg_partman maintenance role                                                                                           |
| `SESSION_SECRET`           | Session secret — `openssl rand -base64 32`                                                                                                          |
| `GOOGLE_CLIENT_ID`         | Google OAuth client ID                                                                                                                              |
| `GOOGLE_CLIENT_SECRET`     | Google OAuth client secret                                                                                                                          |
| `CORS_ORIGIN`              | Allowed frontend origin — only required if frontend and API are on different domains. Single-instance deployments behind nginx do not need this set |
| `ENABLE_REMOTE_DEPLOYMENT` | Set to `true` to enable deploys — omit or leave unset to disable                                                                                    |

### Variables

Non-sensitive config passed via `vars.*`:

| Variable                        | Value                          |
| ------------------------------- | ------------------------------ |
| `API_URL`                       | `api/v1`                       |
| `WEB_SERVER_URL`                | `https://youractualdomain.com` |
| `CERTBOT_EMAIL`                 | `foo@email.com`                |
| `DOMAIN`                        | `youractualdomain.com`         |
| `UNITY_RELEASE_TAG`             | `latest`                       |
| `POSTGRES_HOST`                 | `magic-nugger-postgres`        |
| `PORT`                          | `3000`                         |
| `RPM_LIMIT`                     | `3000`                         |
| `DB_POOL_MAX`                   | `20`                           |
| `DB_POOL_IDLE_TIMEOUT_MS`       | `30000`                        |
| `DB_POOL_CONNECTION_TIMEOUT_MS` | `5000`                         |
| `DB_QUERY_TIMEOUT_MS`           | `30000`                        |
| `DB_SSL_MODE`                   | `prefer`                       |
| `GAME_SESSION_RESUME_WINDOW_MS` | `1800000`                      |

Also create a `production` environment under **GitHub → Settings → Environments** — this gates the deploy workflow and allows adding required reviewers.

> `DATABASE_URL` is constructed by docker-compose from `APP_USER`, `APP_USER_PASSWORD`, and `POSTGRES_DB` — no need to set it as a secret.

---

## 6. Deploy

Push to `master`. The pipeline handles everything:

1. Writes `/magic-nugger/.env` on EC2 from GitHub Secrets
2. Clones the repo to `/magic-nugger` on first run, fetches + resets on subsequent deploys
3. Builds the frontend, rsyncs to `/var/www/magic-nugger/web-app/`, reloads Nginx
4. Builds and starts the server container — migrations run automatically on boot
5. Health-checks `http://127.0.0.1:3000/health`, fails the pipeline if the server doesn't come up

---

## 7. CI/CD Workflows

| Workflow       | Trigger            | What it does                                  |
| -------------- | ------------------ | --------------------------------------------- |
| `test.yml`     | Push to any branch | Runs Jest, writes test summary to job summary |
| `pr-check.yml` | PR to `master`     | Typecheck, lint, Docker build                 |
| `deploy.yml`   | Push to `master`   | Full deploy via composite actions             |

---

## 8. Database Migrations

Migrations run automatically when the server container starts via `entrypoint.sh`.

Manual migration if needed:

```bash
ssh ubuntu@<EC2_IP>
cd /magic-nugger && npm run db:migrate
```

If a migration fails the container exits — fix the patch and restart:

```bash
docker compose restart magic-nugger-web-server
```

---

## 9. Rollback

### Application code

```bash
ssh ubuntu@<EC2_IP>
cd /magic-nugger
git log --oneline -5
git reset --hard <commit-hash>

cd web-app && npm ci && npm run build
sudo rsync -a --delete /magic-nugger/web-app/dist/ /var/www/magic-nugger/web-app/
sudo nginx -s reload

cd /magic-nugger
docker compose build magic-nugger-web-server
docker compose up -d magic-nugger-web-server
```

### Database

```bash
cd /magic-nugger && npm run db:rollback
docker compose restart magic-nugger-web-server
```

Restore from dump if needed:

```bash
docker exec -i magic-nugger-postgres psql -U postgres magic_nugger < backup.sql
```

---

## 10. Backup

### Development

The `magic-nugger-cron` container runs a weekly `pg_dump` every Sunday at 02:00 and writes dumps to `db/backups/` on the host. Logs are written to `audit.log_events` with `event = 'cron:backup'`.

For on-demand snapshots:

```bash
npm run db:backup                                         # → db/backups/backup_YYYYMMDD_HHMMSS.sql
npm run db:restore -- db/backups/backup_20260507_020000.sql
```

See [`docs/007-cron-jobs.md`](docs/007-cron-jobs.md) for full cron job documentation.

### Production

The production stack (`docker-compose.yml`) does not include the cron container — set up a host-level crontab on the EC2 instance:

```bash
# crontab -e (as ubuntu)
0 3 * * 0 docker exec magic-nugger-postgres pg_dump -U postgres magic_nugger > /backups/backup_$(date +\%Y\%m\%d).sql
```

Or pipe to S3:

```bash
0 3 * * 0 docker exec magic-nugger-postgres pg_dump -U postgres magic_nugger | aws s3 cp - s3://your-bucket/magic-nugger-$(date +\%Y\%m\%d).sql
```

---

## 11. Monitoring

```bash
docker compose ps
docker compose logs -f magic-nugger-web-server
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## Architecture

```
Internet
    │
    ▼
┌─────────────┐
│   Nginx     │  SSL termination, static files, rate limiting
│  (host)     │
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
   ▼       ▼
┌──────┐ ┌────────────┐
│ /api │ │ / (static) │
└──┼───┘ └────────────┘
   │
   ▼
┌─────────────────┐
│ server container│  Express 5 + Passport
│   (Node 20)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ postgres cont.  │◄────│  cron container │  session cleanup + backup
│ PostgreSQL 16   │     │  (node:alpine)  │
└─────────────────┘     └─────────────────┘
```
