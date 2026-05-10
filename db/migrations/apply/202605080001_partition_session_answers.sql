BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605080001_partition_session_answers',
      ARRAY['202605020009_create_session_answers', '202605020012_create_pg_partman'],
      'Recreate session_answers as weekly partitioned table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TEMP TABLE _bak_session_answers AS SELECT * FROM session_answers;

        DROP TABLE session_answers;

        CREATE TABLE session_answers (
          id            BIGSERIAL   NOT NULL,
          session_id    UUID        NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
          is_correct    BOOLEAN     NOT NULL,
          elo_delta     INTEGER     NOT NULL,
          time_taken_ms INTEGER,
          answered_at   TIMESTAMPTZ NOT NULL DEFAULT now()
        ) PARTITION BY RANGE (answered_at);

        ALTER TABLE session_answers ADD CONSTRAINT session_answers_pkey PRIMARY KEY (id, answered_at);
        ALTER TABLE session_answers OWNER TO partman_user;

        CREATE INDEX idx_answers_session ON session_answers (session_id, answered_at);

        GRANT SELECT, INSERT, UPDATE, DELETE ON session_answers TO app;
        EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE partman_user IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app';

        PERFORM partman.create_parent(
          p_parent_table => 'public.session_answers',
          p_control      => 'answered_at',
          p_interval     => '1 week',
          p_premake      => 3
        );

        INSERT INTO session_answers SELECT * FROM _bak_session_answers;
        PERFORM setval('session_answers_id_seq', COALESCE((SELECT MAX(id) FROM session_answers), 1));
    END IF;
END $$;

COMMIT;
