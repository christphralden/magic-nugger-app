BEGIN;
SELECT _v.unregister_patch('202605110002_create_levels_unlocked');
DROP TABLE IF EXISTS levels_unlocked;
COMMIT;
