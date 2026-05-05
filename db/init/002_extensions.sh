
#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  -v partman_password="$PARTMAN_PASSWORD" \
<<-EOSQL
    CREATE ROLE partman_user WITH LOGIN PASSWORD :'partman_password';
EOSQL
