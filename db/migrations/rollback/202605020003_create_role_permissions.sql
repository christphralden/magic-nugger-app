BEGIN;
SELECT _v.unregister_patch('202605020003_create_role_permissions');
DROP TABLE IF EXISTS role_permissions CASCADE;
COMMIT;
