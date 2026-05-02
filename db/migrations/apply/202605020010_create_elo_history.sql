BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020010_create_elo_history', 
      ARRAY[
        '202605020004_create_players',
        '202605020008_create_game_sessions'
      ], 
      'Create elo_history table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE elo_history (
          id          BIGSERIAL   PRIMARY KEY,
          player_id   UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          session_id  UUID        REFERENCES game_sessions(id) ON DELETE SET NULL,
          elo_before  INTEGER     NOT NULL,
          elo_after   INTEGER     NOT NULL,
          delta       INTEGER     NOT NULL,
          reason      VARCHAR(32) NOT NULL
                      CHECK (reason IN ('session_completed', 'session_failed', 'admin_adjustment', 'decay')),
          created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
        );

        CREATE INDEX idx_elo_history_player ON elo_history (player_id, created_at DESC);
    END IF;
END $$;

COMMIT;
