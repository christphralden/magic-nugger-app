BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605230001_nullable_level_id_game_sessions',
      ARRAY['202605020008_create_game_sessions'],
      'Make level_id nullable in game_sessions to support room sessions without a level'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE game_sessions ALTER COLUMN level_id DROP NOT NULL;
    END IF;
END $$;

COMMIT;
