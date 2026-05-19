BEGIN;
SELECT _v.unregister_patch('202605190001_room_members_soft_delete');
DROP INDEX IF EXISTS idx_room_members_active;
ALTER TABLE room_members DROP COLUMN IF EXISTS deleted_at;
COMMIT;
