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

| Port | Source    | Purpose  |
| ---- | --------- | -------- |
| 22   | Your IP   | SSH      |
| 80   | 0.0.0.0/0 | HTTP     |
| 443  | 0.0.0.0/0 | HTTPS    |

**Storage:** Add a 20GB EBS volume for Postgres data.

---

## 2. Bootstrap the Server

Run `scripts/bootstrap.sh` as root. The easiest way is to paste it into the EC2 **User Data** field before launching — it runs automatically on first boot. Alternatively, SSH in and run it manually:

```bash
sudo bash scripts/bootstrap.sh
```

This installs Docker, Nginx, Certbot, Node 20, and creates `/app` and `/var/www/magic-nugger/web-app`.

---

## 3. Configure Nginx

Copy the config from this repo to the server and set your domain:

```bash
scp nginx/frontend.nginx.conf ubuntu@<EC2_IP>:/tmp/
ssh ubuntu@<EC2_IP>
sudo cp /tmp/frontend.nginx.conf /etc/nginx/nginx.conf
sudo sed -i 's/your-domain\.com/youractualdomain.com/g' /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl restart nginx
```

---

## 4. SSL (Certbot)

Point your DNS A record to the EC2 public IP first, then:

```bash
sudo certbot --nginx -d youractualdomain.com
```

Certbot adds the 443 block, SSL cert paths, HTTP redirect, and HSTS automatically. Verify auto-renewal:

```bash
sudo certbot renew --dry-run
```

---

## 5. GitHub Secrets

Go to: **GitHub → Settings → Secrets and variables → Actions → New repository secret**

| Secret                 | Description                                            |
| ---------------------- | ------------------------------------------------------ |
| `EC2_HOST`             | Public IP of your EC2                                  |
| `EC2_USERNAME`         | SSH username (`ubuntu` for Ubuntu AMIs)                |
| `EC2_SSH_KEY`          | Private SSH key for the EC2 user                       |
| `DATABASE_URL`         | `postgresql://user:password@postgres:5432/db`          |
| `POSTGRES_USER`        | Postgres superuser name                                |
| `POSTGRES_PASSWORD`    | Postgres superuser password                            |
| `POSTGRES_DB`          | Database name (e.g. `magic_nugger`)                    |
| `SESSION_SECRET`       | Long random string — `openssl rand -base64 32`         |
| `GOOGLE_CLIENT_ID`     | Google OAuth client ID                                 |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret                             |
| `CORS_ORIGIN`          | Frontend origin (e.g. `https://youractualdomain.com`)  |
| `ENABLE_REMOTE_DEPLOYMENT` | Set to `true` to enable deploys — omit or leave unset to disable |

Also create a `production` environment under **GitHub → Settings → Environments** — this gates the deploy workflow and allows adding required reviewers.

---

## 6. Deploy

Push to `master`. The pipeline handles everything:

1. Writes `/app/.env` on EC2 from GitHub Secrets
2. Clones the repo to `/app` on first run, fetches + resets on subsequent deploys
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
cd /app && npm run db:migrate
```

If a migration fails the container exits — fix the patch and restart:

```bash
docker compose restart server
```

---

## 9. Rollback

### Application code

```bash
ssh ubuntu@<EC2_IP>
cd /app
git log --oneline -5
git reset --hard <commit-hash>

cd web-app && npm ci && npm run build
sudo rsync -a --delete /app/web-app/dist/ /var/www/magic-nugger/web-app/
sudo nginx -s reload

cd /app
docker compose build server
docker compose up -d server
```

### Database

```bash
cd /app && npm run db:rollback
docker compose restart server
```

Restore from dump if needed:

```bash
docker exec -i magic-nugger-app-postgres-1 psql -U postgres magic_nugger < backup.sql
```

---

## 10. Backup

Daily Postgres dump to S3:

```bash
# crontab -e
0 3 * * * docker exec magic-nugger-app-postgres-1 pg_dump -U postgres magic_nugger | aws s3 cp - s3://your-bucket/magic-nugger-$(date +\%Y\%m\%d).sql
```

---

## 11. Monitoring

```bash
docker compose ps
docker compose logs -f server
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
┌─────────────────┐
│ postgres cont.  │  PostgreSQL 16 + EBS volume
└─────────────────┘
```
