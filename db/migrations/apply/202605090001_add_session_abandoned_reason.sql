BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605090001_add_session_abandoned_reason',
      ARRAY['202605080002_partition_elo_history'],
      'Add session_abandoned to elo_history reason enum'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE elo_history
          DROP CONSTRAINT elo_history_reason_check,
          ADD CONSTRAINT elo_history_reason_check
            CHECK (reason IN ('session_completed', 'session_failed', 'session_abandoned', 'admin_adjustment', 'decay'));
    END IF;
END $$;

COMMIT;
