BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605190001_room_members_soft_delete',
      ARRAY['202605100002_create_room_members'],
      'Add deleted_at for soft delete on room_members'
    ) INTO patch_registered;

    IF patch_registered THEN
        ALTER TABLE room_members ADD COLUMN deleted_at TIMESTAMPTZ NULL;

        CREATE INDEX idx_room_members_active ON room_members (room_id)
          WHERE deleted_at IS NULL;
    END IF;
END $$;

COMMIT;
