BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605110003_drop_levels_max_score',
      ARRAY['202605020005_create_levels'],
      'Drop max_score column from levels'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE levels DROP COLUMN IF EXISTS max_score;
    END IF;
END $$;

COMMIT;
