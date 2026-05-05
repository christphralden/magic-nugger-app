#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  -v partman_password="$PARTMAN_PASSWORD" \
<<-EOSQL
    CREATE SCHEMA IF NOT EXISTS partman;
    CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;
    CREATE ROLE partman_user WITH LOGIN PASSWORD :'partman_password';
EOSQL
