BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605110002_create_levels_unlocked',
      ARRAY['202605020004_create_players', '202605020005_create_levels'],
      'Create levels_unlocked pivot table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE levels_unlocked (
          player_id   UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          level_id    INTEGER     NOT NULL REFERENCES levels(id)  ON DELETE CASCADE,
          unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
          PRIMARY KEY (player_id, level_id)
        );

        CREATE INDEX idx_levels_unlocked_player ON levels_unlocked (player_id);
    END IF;
END $$;

COMMIT;
