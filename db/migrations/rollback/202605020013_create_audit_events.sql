BEGIN;
SELECT _v.unregister_patch('202605020013_create_audit_events');
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM partman.part_config WHERE parent_table = 'audit.audit_events') THEN
    PERFORM partman.config_cleanup('audit.audit_events');
  END IF;
END $$;
DROP TABLE IF EXISTS partman.template_audit_audit_events;
DROP SCHEMA IF EXISTS audit CASCADE;
COMMIT;
