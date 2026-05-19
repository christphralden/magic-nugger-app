BEGIN;
SELECT _v.unregister_patch('202605100002_create_room_members');
DROP TABLE IF EXISTS room_members CASCADE;
COMMIT;
