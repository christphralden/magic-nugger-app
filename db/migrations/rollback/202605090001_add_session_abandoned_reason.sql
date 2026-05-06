BEGIN;
SELECT _v.unregister_patch('202605090001_add_session_abandoned_reason');

ALTER TABLE elo_history
  DROP CONSTRAINT elo_history_reason_check,
  ADD CONSTRAINT elo_history_reason_check
    CHECK (reason IN ('session_completed', 'session_failed', 'admin_adjustment', 'decay'));

COMMIT;
