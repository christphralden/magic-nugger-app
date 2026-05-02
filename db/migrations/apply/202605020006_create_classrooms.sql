BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020006_create_classrooms', 
      ARRAY['202605020004_create_players'], 
      'Create classrooms table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE classrooms (
          id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
          name         VARCHAR(128) NOT NULL,
          description  TEXT,
          teacher_id   UUID         NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          visibility   VARCHAR(16)  NOT NULL DEFAULT 'private'
                       CHECK (visibility IN ('private', 'public')),
          starting_elo INTEGER      NOT NULL DEFAULT 0,
          elo_cap      INTEGER,
          invite_code  VARCHAR(16)  NOT NULL UNIQUE,
          is_active    BOOLEAN      NOT NULL DEFAULT true,
          created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
          updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
          CONSTRAINT elo_cap_above_floor CHECK (elo_cap IS NULL OR elo_cap > starting_elo)
        );

        CREATE INDEX idx_classrooms_teacher ON classrooms (teacher_id);
        CREATE INDEX idx_classrooms_invite  ON classrooms (invite_code);
    END IF;
END $$;

COMMIT;
