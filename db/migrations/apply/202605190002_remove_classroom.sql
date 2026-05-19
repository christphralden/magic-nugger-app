BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605190002_remove_classroom',
      ARRAY[
        '202605100001_create_rooms',
        '202605020006_create_classrooms',
        '202605020007_create_classroom_members'
      ],
      'Remove classroom tables and rooms.classroom_id column'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_type_check;
        ALTER TABLE rooms ADD CONSTRAINT rooms_type_check CHECK (type IN ('pvp'));
        ALTER TABLE rooms DROP COLUMN IF EXISTS classroom_id;

        DROP TABLE IF EXISTS classroom_members CASCADE;
        DROP TABLE IF EXISTS classrooms CASCADE;
    END IF;
END $$;

COMMIT;
