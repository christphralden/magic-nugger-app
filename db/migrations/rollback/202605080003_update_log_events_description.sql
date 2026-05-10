BEGIN;
SELECT _v.unregister_patch('202605080003_update_log_events_description');
ALTER TABLE audit.log_events DROP COLUMN IF EXISTS description;
DO $$
DECLARE v_template text;
BEGIN
  SELECT template_table INTO v_template
  FROM partman.part_config WHERE parent_table = 'audit.log_events';
  IF v_template IS NOT NULL THEN
    EXECUTE format('ALTER TABLE %s DROP COLUMN IF EXISTS description', v_template);
  END IF;
END $$;
COMMIT;
