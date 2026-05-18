BEGIN;
SELECT _v.unregister_patch('202605190002_rooms_custom_game');
ALTER TABLE rooms DROP COLUMN IF EXISTS questions;
ALTER TABLE rooms ALTER COLUMN level_id SET NOT NULL;
ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_status_check;
ALTER TABLE rooms ADD CONSTRAINT rooms_status_check
  CHECK (status IN ('waiting', 'in_progress', 'completed', 'cancelled'));
COMMIT;
