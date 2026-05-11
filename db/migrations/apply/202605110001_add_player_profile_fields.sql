BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605110001_add_player_profile_fields',
      ARRAY['202605020004_create_players'],
      'Add age, grade, guardian_email to players'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE players
          ADD COLUMN age            SMALLINT     CHECK (age > 0),
          ADD COLUMN grade          SMALLINT     CHECK (grade > 0),
          ADD COLUMN guardian_email VARCHAR(255);
    END IF;
END $$;

COMMIT;
