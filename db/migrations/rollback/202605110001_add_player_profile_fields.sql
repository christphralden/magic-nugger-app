BEGIN;
SELECT _v.unregister_patch('202605110001_add_player_profile_fields');
ALTER TABLE players DROP COLUMN IF EXISTS age, DROP COLUMN IF EXISTS grade, DROP COLUMN IF EXISTS guardian_email;
COMMIT;
