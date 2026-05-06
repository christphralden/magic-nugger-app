---
Date: 2026-05-07
Author: christphralden
Title: 007-cron-jobs
---

Background maintenance tasks run in a dedicated `magic-nugger-cron`

## Container

**Source:** `db/cron/`  
**Base image:** `node:20-alpine` + `postgresql-client`  
**Connects to:** Postgres via `POSTGRES_*` env vars (same pattern as `db/runner.mjs`)  
**Docker Compose service:** `magic-nugger-cron-dev` (dev only)

The container runs BusyBox `crond` in the foreground. All job output is redirected to `/proc/1/fd/1` so it appears in `docker logs magic-nugger-cron-dev`.

Every job run — success or failure — inserts a row into `audit.log_events` with `event = 'cron:<job>'`.

---

## Jobs

### Game Session Cleanup

| Property | Value                                                    |
| -------- | -------------------------------------------------------- |
| Script   | `db/cron/game-session-cleanup.mjs`                       |
| Schedule | `0 * * * *` — every hour, on the hour                    |
| Purpose  | Mark orphaned `in_progress` game sessions as `abandoned` |

#### What it does

Game sessions stay `in_progress` until the client explicitly calls the end or abandon API. If a player disconnects mid-game and never returns, their session is never cleaned up. This job finds all `in_progress` sessions whose `started_at` is older than `GAME_SESSION_RESUME_WINDOW_MS` and sets their `status = 'abandoned'` and `ended_at = now()`.

```sql
UPDATE game_sessions
SET status = 'abandoned', ended_at = now()
WHERE status = 'in_progress'
  AND started_at < now() - ($1 || ' milliseconds')::interval
```

#### Log events written

| Outcome | `event`                     | `level` | `metadata`                                    |
| ------- | --------------------------- | ------- | --------------------------------------------- |
| Success | `cron:game-session-cleanup` | `info`  | `{ count, session_ids, source, duration_ms }` |
| Error   | `cron:game-session-cleanup` | `error` | `{ error }`                                   |

#### Env vars

| Variable                        | Default   | Description                                     |
| ------------------------------- | --------- | ----------------------------------------------- |
| `GAME_SESSION_RESUME_WINDOW_MS` | `1800000` | Sessions older than this are abandoned (30 min) |

This variable is shared with the web server — changing it in one place affects both the in-request resume check and the hourly cleanup threshold.

#### Run manually

```bash
# use -t to allocate a TTY so that when logged emits source:"manual instead of cron"
docker exec -t magic-nugger-cron-dev node /app/game-session-cleanup.mjs
```

---

### Weekly Backup

| Property | Value                          |
| -------- | ------------------------------ |
| Script   | `db/cron/backup.sh`            |
| Schedule | `0 2 * * 0` — Sunday at 02:00  |
| Purpose  | Full `pg_dump` of the database |

#### What it does

Runs `pg_dump` inside the cron container and writes a plain SQL dump to `/backups/backup_YYYYMMDD_HHMMSS.sql`, which is volume-mounted from `./db/backups/` on the host.

Dumps accumulate in `db/backups/` — clean them up manually when disk space is a concern. The directory is gitignored.

#### Log events written

| Outcome | `event`       | `level` | `metadata`        |
| ------- | ------------- | ------- | ----------------- |
| Success | `cron:backup` | `info`  | `{ file }`        |
| Error   | `cron:backup` | `error` | `{ error, file }` |

#### Run manually (from cron container)

```bash
docker exec magic-nugger-cron-dev sh /app/backup.sh
docker exec -i magic-nugger-cron-dev psql -U "POSTGRES_USER" "POSTGRES_DB" < <path-to-backup.sql>
```

---

## Manual Backup and Restore (host-side)

For on-demand snapshots outside of the weekly schedule. These use `docker exec` into the running dev postgres container — no local `pg_dump` install required.

```bash
# Create a snapshot → db/backups/backup_YYYYMMDD_HHMMSS.sql
npm run db:backup

# Restore from a snapshot
npm run db:restore -- db/backups/backup_20260507_020000.sql
```

> Restore replays the entire SQL dump against the running database. Run it against a clean DB or be prepared for duplicate key errors on existing data.

---

## Checking Logs

```bash
# Live output from the cron container
docker logs -f magic-nugger-cron-dev

# Query audit.log_events for cron history
psql $DATABASE_URL -c "
  SELECT event, level, metadata, created_at
  FROM audit.log_events
  WHERE event LIKE 'cron:%'
  ORDER BY created_at DESC
  LIMIT 20;
"
```

---

## Starting the Cron Container

```bash
# Start alongside postgres (cron depends_on postgres healthy)
docker compose --env-file=.env.local -f docker-compose.dev.yml up -d magic-nugger-cron

# Or start everything at once
docker compose --env-file=.env.local -f docker-compose.dev.yml up -d
```

---

## File Layout

```
db/
├── cron/
│   ├── Dockerfile
│   ├── package.json
│   ├── crontab                     # schedule definitions
│   ├── game-session-cleanup.mjs    # abandons orphaned sessions
│   ├── log-event.mjs               # CLI helper: insert one audit.log_events row
│   └── backup.sh                   # pg_dump → /backups
├── backups/
├── backup.sh
└── restore.sh
```
