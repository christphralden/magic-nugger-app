BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605100003_add_room_id_to_game_sessions',
      ARRAY[
        '202605100001_create_rooms',
        '202605020008_create_game_sessions'
      ],
      'Add room_id FK to game_sessions'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE game_sessions
          ADD COLUMN room_id UUID REFERENCES rooms(id) ON DELETE SET NULL;

        CREATE INDEX idx_sessions_room ON game_sessions (room_id)
          WHERE room_id IS NOT NULL;
    END IF;
END $$;

COMMIT;
