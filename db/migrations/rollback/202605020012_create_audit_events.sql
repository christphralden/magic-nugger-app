BEGIN;
SELECT _v.unregister_patch('202605020012_create_audit_events');
DROP SCHEMA IF EXISTS audit CASCADE;
COMMIT;
