BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020004_create_players', 
      ARRAY['202605020002_create_roles'], 
      'Create players table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE players (
          id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
          username                 VARCHAR(32) NOT NULL UNIQUE,
          display_name             VARCHAR(64),
          email                    VARCHAR(255) NOT NULL UNIQUE,
          avatar_url               TEXT,
          role_id                  INTEGER     NOT NULL DEFAULT 1 REFERENCES roles(id),
          oauth_provider           VARCHAR(32),
          oauth_id                 VARCHAR(255),
          password_hash            TEXT,
          current_elo              INTEGER     NOT NULL DEFAULT 0,
          highest_level_unlocked   INTEGER     NOT NULL DEFAULT 1,
          total_questions_answered INTEGER     NOT NULL DEFAULT 0,
          total_correct            INTEGER     NOT NULL DEFAULT 0,
          total_incorrect          INTEGER     NOT NULL DEFAULT 0,
          longest_streak           INTEGER     NOT NULL DEFAULT 0,
          created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
          updated_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
          last_active_at           TIMESTAMPTZ,
          CONSTRAINT oauth_or_password CHECK (
            (oauth_provider IS NOT NULL AND oauth_id IS NOT NULL) OR
            (password_hash IS NOT NULL)
          )
        );

        CREATE INDEX idx_players_elo   ON players (current_elo DESC);
        CREATE INDEX idx_players_email ON players (email);
        CREATE INDEX idx_players_oauth ON players (oauth_provider, oauth_id)
          WHERE oauth_provider IS NOT NULL;
    END IF;
END $$;

COMMIT;
