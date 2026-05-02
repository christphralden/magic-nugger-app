BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020008_create_game_sessions', 
      ARRAY[
        '202605020004_create_players',
        '202605020005_create_levels'
      ], 
      'Create game_sessions table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE game_sessions (
          id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
          player_id       UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          level_id        INTEGER     NOT NULL REFERENCES levels(id),
          status          VARCHAR(16) NOT NULL DEFAULT 'in_progress'
                          CHECK (status IN ('in_progress', 'completed', 'failed', 'abandoned')),
          score           INTEGER     NOT NULL DEFAULT 0,
          max_answers     INTEGER     NOT NULL DEFAULT 0,
          elo_before      INTEGER     NOT NULL,
          elo_after       INTEGER,
          elo_delta       INTEGER,
          correct_count   INTEGER     NOT NULL DEFAULT 0,
          incorrect_count INTEGER     NOT NULL DEFAULT 0,
          max_streak      INTEGER     NOT NULL DEFAULT 0,
          current_streak  INTEGER     NOT NULL DEFAULT 0,
          started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
          ended_at        TIMESTAMPTZ,
          client_ip       INET,
          user_agent      TEXT
        );

        CREATE INDEX idx_sessions_player ON game_sessions (player_id, started_at DESC);
        CREATE INDEX idx_sessions_level  ON game_sessions (level_id, score DESC)
          WHERE status = 'completed';
    END IF;
END $$;

COMMIT;
