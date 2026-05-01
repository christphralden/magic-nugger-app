BEGIN;
SELECT _v.unregister_patch('202605020004_create_players');
DROP TABLE IF EXISTS players CASCADE;
COMMIT;
