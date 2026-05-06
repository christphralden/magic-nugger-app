#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env.local"

FILE="${1:?Usage: npm run db:restore -- <path-to-dump.sql>}"
docker exec -i magic-nugger-postgres-dev psql -U "$POSTGRES_USER" "$POSTGRES_DB" < "$FILE"
echo "Restored from $FILE"
