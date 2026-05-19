BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605100002_create_room_members',
      ARRAY[
        '202605100001_create_rooms',
        '202605020008_create_game_sessions'
      ],
      'Create room_members table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE room_members (
          room_id         UUID        NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
          player_id       UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          game_session_id UUID        REFERENCES game_sessions(id) ON DELETE SET NULL,
          joined_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
          PRIMARY KEY (room_id, player_id)
        );

        CREATE INDEX idx_room_members_player  ON room_members (player_id);
        CREATE INDEX idx_room_members_session ON room_members (game_session_id)
          WHERE game_session_id IS NOT NULL;
    END IF;
END $$;

COMMIT;
