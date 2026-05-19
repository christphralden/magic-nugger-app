BEGIN;
SELECT _v.unregister_patch('202605100001_create_rooms');
DROP TABLE IF EXISTS rooms CASCADE;
COMMIT;
