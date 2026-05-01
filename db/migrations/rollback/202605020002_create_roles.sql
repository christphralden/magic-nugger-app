BEGIN;
SELECT _v.unregister_patch('202605020002_create_roles');
DROP TABLE IF EXISTS roles CASCADE;
COMMIT;
