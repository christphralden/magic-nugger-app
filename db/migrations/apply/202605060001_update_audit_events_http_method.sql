-- Update audit event to capture http method
BEGIN;

DO $$
DECLARE
  patch_registered bool default false;
  v_template text;
BEGIN
    SELECT _v.try_register_patch(
      '202605060001_update_audit_events_http_method',
      ARRAY['202605020013_create_audit_events'],
      'Update audit schema to capture http method'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE audit.audit_events
        ADD COLUMN http_method VARCHAR(10) DEFAULT NULL;

        SELECT template_table INTO v_template
        FROM partman.part_config WHERE parent_table = 'audit.audit_events';
        IF v_template IS NOT NULL THEN
          EXECUTE format(
            'ALTER TABLE %s ADD COLUMN IF NOT EXISTS http_method VARCHAR(10) DEFAULT NULL',
            v_template
          );
        END IF;
    END IF;
END $$;

COMMIT;
