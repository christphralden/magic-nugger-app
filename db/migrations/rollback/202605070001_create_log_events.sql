BEGIN;
SELECT _v.unregister_patch('202605070001_create_log_events');
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM partman.part_config WHERE parent_table = 'audit.log_events') THEN
    PERFORM partman.config_cleanup('audit.log_events');
  END IF;
END $$;
DROP TABLE IF EXISTS partman.template_audit_log_events;
DROP TABLE IF EXISTS audit.log_events CASCADE;
COMMIT;
