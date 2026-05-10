#!/usr/bin/env sh
set -e

OUTFILE="/backups/backup_$(date +%Y%m%d_%H%M%S).sql"

if PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" "$POSTGRES_DB" > "$OUTFILE"; then
  echo "[backup] written to $OUTFILE"
  node /app/log-event.mjs "cron:backup" "info" "{\"file\":\"$OUTFILE\"}"
else
  node /app/log-event.mjs "cron:backup" "error" "{\"error\":\"pg_dump failed\",\"file\":\"$OUTFILE\"}"
  exit 1
fi
