BEGIN;
SELECT _v.unregister_patch('202605020009_create_session_answers');
DROP TABLE IF EXISTS session_answers CASCADE;
COMMIT;
