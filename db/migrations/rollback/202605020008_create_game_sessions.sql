BEGIN;
SELECT _v.unregister_patch('202605020008_create_game_sessions');
DROP TABLE IF EXISTS game_sessions CASCADE;
COMMIT;
