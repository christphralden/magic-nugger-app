BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605190002_rooms_custom_game',
      ARRAY['202605100001_create_rooms'],
      'Add questions JSONB, nullable level_id, creation status to rooms'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE rooms ADD COLUMN questions JSONB NULL;

        ALTER TABLE rooms ALTER COLUMN level_id DROP NOT NULL;

        ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_type_check;
        ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_status_check;
        ALTER TABLE rooms ADD CONSTRAINT rooms_status_check
          CHECK (status IN ('creation', 'waiting', 'in_progress', 'completed', 'cancelled'));
    END IF;
END $$;

COMMIT;
