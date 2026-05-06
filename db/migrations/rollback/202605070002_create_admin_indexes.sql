BEGIN;
SELECT _v.unregister_patch('202605070002_create_admin_indexes');
DROP INDEX IF EXISTS idx_players_created;
DROP INDEX IF EXISTS idx_sessions_started;
DROP INDEX IF EXISTS idx_sessions_status_started;
COMMIT;
