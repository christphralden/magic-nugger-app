BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020005_create_levels', 
      ARRAY['202605020000_patch_infrastructure'], 
      'Create levels table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE levels (
          id                  SERIAL,
          name                VARCHAR(64) NOT NULL PRIMARY KEY,
          description         TEXT,
          order_index         INTEGER     NOT NULL,
          child_levels        TEXT[],
          elo_min             INTEGER     NOT NULL DEFAULT 0,
          elo_gain_correct    INTEGER     NOT NULL DEFAULT 15,
          elo_loss_incorrect  INTEGER     NOT NULL DEFAULT 5,
          time_limit_seconds  INTEGER,
          enemy_wave_config   JSONB       NOT NULL DEFAULT '{}',
          question_gen_config JSONB       NOT NULL DEFAULT '{}',
          is_active           BOOLEAN     NOT NULL DEFAULT true,
          created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
          updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
          UNIQUE (id)
        );
    END IF;
END $$;

COMMIT;
