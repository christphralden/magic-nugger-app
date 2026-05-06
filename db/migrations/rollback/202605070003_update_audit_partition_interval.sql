BEGIN;
SELECT _v.unregister_patch('202605070003_update_audit_partition_interval');
DO $$
BEGIN
    UPDATE partman.part_config
    SET partition_interval = '1 month'
    WHERE parent_table IN ('audit.audit_events', 'audit.log_events');

    PERFORM partman.run_maintenance();
END $$;
COMMIT;
