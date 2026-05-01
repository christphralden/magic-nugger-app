BEGIN;
SELECT _v.unregister_patch('202605020010_create_elo_history');
DROP TABLE IF EXISTS elo_history CASCADE;
COMMIT;
