BEGIN;
SELECT _v.unregister_patch('202605020007_create_classroom_members');
DROP TABLE IF EXISTS classroom_members CASCADE;
COMMIT;
