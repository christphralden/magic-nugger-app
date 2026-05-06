BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605080002_partition_elo_history',
      ARRAY['202605020010_create_elo_history', '202605020012_create_pg_partman'],
      'Recreate elo_history as weekly partitioned table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TEMP TABLE _bak_elo_history AS SELECT * FROM elo_history;

        DROP TABLE elo_history;

        CREATE TABLE elo_history (
          id          BIGSERIAL   NOT NULL,
          player_id   UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
          session_id  UUID        REFERENCES game_sessions(id) ON DELETE SET NULL,
          elo_before  INTEGER     NOT NULL,
          elo_after   INTEGER     NOT NULL,
          delta       INTEGER     NOT NULL,
          reason      VARCHAR(32) NOT NULL
                      CHECK (reason IN ('session_completed', 'session_failed', 'admin_adjustment', 'decay')),
          created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
        ) PARTITION BY RANGE (created_at);

        ALTER TABLE elo_history ADD CONSTRAINT elo_history_pkey PRIMARY KEY (id, created_at);
        ALTER TABLE elo_history OWNER TO partman_user;

        CREATE INDEX idx_elo_history_player ON elo_history (player_id, created_at DESC);

        GRANT SELECT, INSERT, UPDATE, DELETE ON elo_history TO app;

        PERFORM partman.create_parent(
          p_parent_table => 'public.elo_history',
          p_control      => 'created_at',
          p_interval     => '1 week',
          p_premake      => 3
        );

        INSERT INTO elo_history SELECT * FROM _bak_elo_history;
        PERFORM setval('elo_history_id_seq', COALESCE((SELECT MAX(id) FROM elo_history), 1));
    END IF;
END $$;

COMMIT;
