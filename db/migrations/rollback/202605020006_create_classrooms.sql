BEGIN;
SELECT _v.unregister_patch('202605020006_create_classrooms');
DROP TABLE IF EXISTS classrooms CASCADE;
COMMIT;
