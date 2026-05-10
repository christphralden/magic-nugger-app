-- Add indexes to support admin route keyset pagination on timestamp columns
BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605070002_create_admin_indexes',
      ARRAY['202605020004_create_players', '202605020008_create_game_sessions'],
      'Add indexes for admin pagination queries on players and game_sessions'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE INDEX idx_players_created ON players (created_at DESC);

        CREATE INDEX idx_sessions_started ON game_sessions (started_at DESC);

        CREATE INDEX idx_sessions_status_started ON game_sessions (status, started_at DESC);
    END IF;
END $$;

COMMIT;
