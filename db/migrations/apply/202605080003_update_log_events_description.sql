-- Update log event to have description
BEGIN;

DO $$
DECLARE
  patch_registered bool default false;
  v_template text;
BEGIN
    SELECT _v.try_register_patch(
      '202605080003_update_log_events_description',
      ARRAY['202605070001_create_log_events', '202605020013_create_audit_events'],
      'Update log schema to have description'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE audit.log_events
        ADD COLUMN description TEXT DEFAULT NULL;

        SELECT template_table INTO v_template
        FROM partman.part_config WHERE parent_table = 'audit.log_events';
        IF v_template IS NOT NULL THEN
          EXECUTE format(
            'ALTER TABLE %s ADD COLUMN IF NOT EXISTS description TEXT DEFAULT NULL',
            v_template
          );
        END IF;
    END IF;
END $$;

COMMIT;
