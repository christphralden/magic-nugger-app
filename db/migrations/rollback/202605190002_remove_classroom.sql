BEGIN;
SELECT _v.unregister_patch('202605190002_remove_classroom');

CREATE TABLE IF NOT EXISTS classrooms (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name         VARCHAR(128) NOT NULL,
  description  TEXT,
  teacher_id   UUID         NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  visibility   VARCHAR(16)  NOT NULL DEFAULT 'private' CHECK (visibility IN ('private', 'public')),
  starting_elo INTEGER      NOT NULL DEFAULT 0,
  elo_cap      INTEGER,
  invite_code  VARCHAR(16)  NOT NULL UNIQUE,
  is_active    BOOLEAN      NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS classroom_members (
  classroom_id UUID    NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
  player_id    UUID    NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  classroom_elo INTEGER NOT NULL DEFAULT 0,
  joined_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (classroom_id, player_id)
);

ALTER TABLE rooms ADD COLUMN IF NOT EXISTS classroom_id UUID REFERENCES classrooms(id) ON DELETE SET NULL;
ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_type_check;
ALTER TABLE rooms ADD CONSTRAINT rooms_type_check CHECK (type IN ('classroom', 'pvp'));
COMMIT;
