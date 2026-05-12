BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605120001_drop_game_sessions_max_answers',
      ARRAY['202605020008_create_game_sessions'],
      'Drop max_answers column from game_sessions'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE game_sessions DROP COLUMN IF EXISTS max_answers;
    END IF;
END $$;

COMMIT;
