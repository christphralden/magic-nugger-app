BEGIN;
SELECT _v.unregister_patch('202605060001_update_audit_events_http_method');
ALTER TABLE audit.audit_events DROP COLUMN IF EXISTS http_method;
DO $$
DECLARE v_template text;
BEGIN
  SELECT template_table INTO v_template
  FROM partman.part_config WHERE parent_table = 'audit.audit_events';
  IF v_template IS NOT NULL THEN
    EXECUTE format('ALTER TABLE %s DROP COLUMN IF EXISTS http_method', v_template);
  END IF;
END $$;
COMMIT;
