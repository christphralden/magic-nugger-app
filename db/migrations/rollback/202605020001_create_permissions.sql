BEGIN;
SELECT _v.unregister_patch('202605020001_create_permissions');
DROP TABLE IF EXISTS permissions CASCADE;
COMMIT;
