BEGIN;
SELECT _v.unregister_patch('202605100003_add_room_id_to_game_sessions');
DROP INDEX IF EXISTS idx_sessions_room;
ALTER TABLE game_sessions DROP COLUMN IF EXISTS room_id;
COMMIT;
