#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  -v app_user="$APP_USER" \
  -v app_password="$APP_USER_PASSWORD" \
  -v app_ro_user="$APP_RO_USER" \
  -v app_ro_password="$APP_RO_PASSWORD" \
  -v db_name="$POSTGRES_DB" \
<<-EOSQL
    CREATE USER :"app_user" WITH PASSWORD :'app_password';
    GRANT CONNECT ON DATABASE :"db_name" TO :"app_user";
    GRANT USAGE ON SCHEMA public TO :"app_user";
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO :"app_user";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"app_user";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO :"app_user";

    CREATE USER :"app_ro_user" WITH PASSWORD :'app_ro_password';
    GRANT CONNECT ON DATABASE :"db_name" TO :"app_ro_user";
    GRANT USAGE ON SCHEMA public TO :"app_ro_user";
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO :"app_ro_user";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO :"app_ro_user";
EOSQL
