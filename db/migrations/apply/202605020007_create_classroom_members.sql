BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020007_create_classroom_members', 
      ARRAY[
        '202605020006_create_classrooms',
        '202605020004_create_players'
      ], 
      'Create classroom_members table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE classroom_members (
          classroom_id  UUID    NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
          player_id     UUID    NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          classroom_elo INTEGER NOT NULL,
          joined_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
          PRIMARY KEY (classroom_id, player_id)
        );

        CREATE INDEX idx_members_player ON classroom_members (player_id);
    END IF;
END $$;

COMMIT;
