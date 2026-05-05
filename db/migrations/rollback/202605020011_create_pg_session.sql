BEGIN;
SELECT _v.unregister_patch('202605020011_create_pg_session');
DROP TABLE IF EXISTS "session" CASCADE;
COMMIT;
