BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020012_create_pg_partman',
      NULL,
      'Create partman schema and install pg_partman extension'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE SCHEMA IF NOT EXISTS partman;
        CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;

        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'partman_user') THEN
            CREATE ROLE partman_user;
        END IF;

        GRANT USAGE ON SCHEMA partman TO partman_user;
        GRANT ALL ON ALL TABLES IN SCHEMA partman TO partman_user;
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA partman TO partman_user;
        GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA partman TO partman_user;
        EXECUTE format('GRANT TEMPORARY ON DATABASE %I TO partman_user', current_database());
    END IF;
END $$;

COMMIT;
