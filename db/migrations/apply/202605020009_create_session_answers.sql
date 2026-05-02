BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020009_create_session_answers', 
      ARRAY['202605020008_create_game_sessions'], 
      'Create session_answers table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE session_answers (
          id            BIGSERIAL   PRIMARY KEY,
          session_id    UUID        NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
          is_correct    BOOLEAN     NOT NULL,
          elo_delta     INTEGER     NOT NULL,
          time_taken_ms INTEGER,
          answered_at   TIMESTAMPTZ NOT NULL DEFAULT now()
        );

        CREATE INDEX idx_answers_session ON session_answers (session_id, answered_at);
    END IF;
END $$;

COMMIT;
