# Deployment Guide

Single EC2 instance running Docker Compose. Nginx on the host handles static files + reverse proxy. SSL via Certbot.

---

## Prerequisites

- AWS account
- Registered domain (or subdomain) pointing to your EC2 public IP
- GitHub repository with `master` branch

---

## 1. Provision EC2

Launch an Ubuntu 22.04 LTS `t3.micro` (or larger) with:

| Port | Source | Purpose |
|---|---|---|
| 22 | Your IP | SSH |
| 80 | 0.0.0.0/0 | HTTP → Nginx redirect to HTTPS |
| 443 | 0.0.0.0/0 | HTTPS |

**Storage:** Add a 20GB EBS volume for Postgres data.

---

## 2. Initial Server Setup

SSH into the instance and install dependencies:

```bash
sudo apt update && sudo apt upgrade -y

# Docker
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
newgrp docker

# Nginx + Certbot
sudo apt install -y nginx certbot python3-certbot-nginx

# Node (for running migrations from host if needed)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

---

## 3. Clone & Configure

```bash
sudo mkdir -p /app
sudo chown $USER:$USER /app
cd /app
git clone https://github.com/YOUR_ORG/magic-nugger-app.git .
```

Create the production `.env`:

```bash
cp .env.example .env
nano .env
```

Fill in real values:

```bash
DATABASE_URL=postgresql://postgres:YOUR_DB_PASSWORD@postgres:5432/magic_nugger
SESSION_SECRET=generate-a-long-random-string
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
NODE_ENV=production
CORS_ORIGIN=https://your-domain.com
PORT=3000
```

Generate a session secret:

```bash
openssl rand -base64 32
```

---

## 4. Nginx Setup

Copy the frontend config:

```bash
sudo cp nginx/frontend.nginx.conf /etc/nginx/nginx.conf
```

**Edit** `/etc/nginx/nginx.conf` and replace `server_name _;` with your actual domain:

```nginx
server_name your-domain.com;
```

Create the web app static directory:

```bash
sudo mkdir -p /var/www/magic-nugger/web-app
```

Test and reload:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

## 5. SSL (Certbot)

```bash
sudo certbot --nginx -d your-domain.com
```

Follow prompts. Certbot will modify the Nginx config automatically.

Auto-renewal is handled by a systemd timer (installed by certbot). Verify:

```bash
sudo certbot renew --dry-run
```

---

## 6. Build & Start

Build the web app for production:

```bash
cd /app/web-app && npm ci && npm run build
sudo cp -r /app/web-app/dist/* /var/www/magic-nugger/web-app/
```

Start services:

```bash
cd /app
docker compose up -d
```

The server container will automatically run migrations via `entrypoint.sh` on boot.

Check status:

```bash
docker compose ps
docker compose logs -f server
```

---

## 7. Database Migrations in Production

Migrations run automatically when the server container starts (via `entrypoint.sh`).

If you need to run a migration manually:

```bash
cd /app
npm run db:migrate
```

If a migration fails, the server container exits and Docker Compose marks it as unhealthy. Fix the patch, then restart:

```bash
docker compose restart server
```

---

## 8. CI/CD (GitHub Actions)

The deploy workflow (`.github/workflows/deploy.yml`) runs on every push to `master`.

**Required GitHub secrets:**

| Secret | Description |
|---|---|
| `EC2_HOST` | Public IP of your EC2 |
| `EC2_SSH_KEY` | Private SSH key for the EC2 `ubuntu` user |

**What the deploy does:**

1. SSH into EC2
2. `git pull origin master`
3. `docker compose pull`
4. `docker compose up -d --build`
5. The server container auto-runs migrations on boot

**To set up secrets:**

GitHub → Settings → Secrets and variables → Actions → New repository secret

---

## 9. Updating Static Files

The web app is served as static files by Nginx (not a container). After any frontend deploy, rebuild and copy:

```bash
cd /app/web-app && npm ci && npm run build
sudo cp -r /app/web-app/dist/* /var/www/magic-nugger/web-app/
```

Or automate this in the deploy workflow by adding a step that runs the copy command over SSH.

---

## 10. Rollback

### Rollback application code

```bash
cd /app
git log --oneline -5          # find the last good commit
git checkout <commit-hash>    # or git revert <bad-commit>
docker compose up -d --build
```

### Rollback database

```bash
cd /app
npm run db:rollback   # rolls back the most recent patch
docker compose restart server
```

If the rollback itself is broken, restore from a Postgres dump:

```bash
# Restore from a pre-deploy dump
docker exec -i magic-nugger-app-postgres-1 psql -U postgres magic_nugger < backup.sql
```

---

## 11. Backup Strategy

Daily Postgres dump to S3 (recommended):

```bash
# Add to crontab
0 3 * * * docker exec magic-nugger-app-postgres-1 pg_dump -U postgres magic_nugger | aws s3 cp - s3://your-backup-bucket/magic-nugger-$(date +\%Y\%m\%d).sql
```

---

## 12. Monitoring

Check container health:

```bash
docker compose ps
docker compose logs -f server
docker compose logs -f postgres
```

Nginx logs:

```bash
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
│  │   │ │            │
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
│  (data persist) │
└─────────────────┘
```
