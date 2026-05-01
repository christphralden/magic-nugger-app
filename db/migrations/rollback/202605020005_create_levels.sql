BEGIN;
SELECT _v.unregister_patch('202605020005_create_levels');
DROP TABLE IF EXISTS levels CASCADE;
COMMIT;
