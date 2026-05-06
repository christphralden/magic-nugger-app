BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605070002_update_audit_partition_interval',
      ARRAY['202605020013_create_audit_events'],
      'Update audit partition interval from 1 month to 1 week'
    ) INTO patch_registered;

    IF patch_registered THEN
        UPDATE partman.part_config
        SET partition_interval = '1 week'
        WHERE parent_table IN ('audit.audit_events', 'audit.log_events');

        PERFORM partman.run_maintenance();
    END IF;
END $$;

COMMIT;
