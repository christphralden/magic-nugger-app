
BEGIN;
SELECT _v.unregister_patch('202605060001_update_audit_events_http_method');
ALTER TABLE audit.audit_events DROP COLUMN "http_method";
COMMIT;
