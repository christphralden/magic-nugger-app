BEGIN;

DO $$
BEGIN
    ALTER TABLE game_sessions ALTER COLUMN level_id SET NOT NULL;
    PERFORM _v.unregister_patch('202605230001_nullable_level_id_game_sessions');
END $$;

COMMIT;
