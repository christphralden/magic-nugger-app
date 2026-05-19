BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605100001_create_rooms',
      ARRAY[
        '202605020004_create_players',
        '202605020005_create_levels',
        '202605020006_create_classrooms'
      ],
      'Create rooms table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE rooms (
          id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
          host_id      UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          classroom_id UUID        REFERENCES classrooms(id) ON DELETE SET NULL,
          level_id     INTEGER     NOT NULL REFERENCES levels(id),
          type         VARCHAR(16) NOT NULL DEFAULT 'pvp'
                       CHECK (type IN ('classroom', 'pvp')),
          status       VARCHAR(16) NOT NULL DEFAULT 'waiting'
                       CHECK (status IN ('waiting', 'in_progress', 'completed', 'cancelled')),
          invite_code  VARCHAR(16) NOT NULL UNIQUE,
          max_players  INTEGER     NOT NULL DEFAULT 10
                       CHECK (max_players BETWEEN 2 AND 50),
          started_at   TIMESTAMPTZ,
          ended_at     TIMESTAMPTZ,
          created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
          updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
        );

        CREATE INDEX idx_rooms_host      ON rooms (host_id);
        CREATE INDEX idx_rooms_classroom ON rooms (classroom_id) WHERE classroom_id IS NOT NULL;
        CREATE INDEX idx_rooms_invite    ON rooms (invite_code);
        CREATE INDEX idx_rooms_status    ON rooms (status) WHERE status IN ('waiting', 'in_progress');
    END IF;
END $$;

COMMIT;
