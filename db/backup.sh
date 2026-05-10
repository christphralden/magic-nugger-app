#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env.local"

mkdir -p "$(dirname "$0")/backups"
OUTFILE="$(dirname "$0")/backups/backup_$(date +%Y%m%d_%H%M%S).sql"

docker exec magic-nugger-postgres-dev pg_dump --clean --if-exists -U "$POSTGRES_USER" "$POSTGRES_DB" > "$OUTFILE"
echo "Backup written to $OUTFILE"
