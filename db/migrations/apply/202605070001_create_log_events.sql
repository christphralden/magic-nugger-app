-- Create log events to track specified events or errors
BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605070001_create_log_events',
      -- we have to rely on 202605020013_create_audit_events for audit schema creation ffs
      ARRAY['202605020012_create_pg_partman','202605020013_create_audit_events'],
      'Create log schema and partitioned log events table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE audit.log_events (
          id          UUID         NOT NULL DEFAULT gen_random_uuid(),
          user_id     UUID         REFERENCES players(id) ON DELETE SET NULL,
          event       VARCHAR(255) NOT NULL,
          level       VARCHAR(16)  NOT NULL DEFAULT 'info',
                      CHECK (level IN ('info', 'warning', 'error', 'fatal')),
          metadata    JSONB,
          created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
        ) PARTITION BY RANGE (created_at);

        ALTER TABLE audit.log_events ADD CONSTRAINT log_events_pkey PRIMARY KEY (id, created_at);
        ALTER TABLE audit.log_events OWNER TO partman_user;

        CREATE INDEX idx_log_events_event         ON audit.log_events   (event);
        CREATE INDEX idx_log_events_created_at    ON audit.log_events (created_at DESC);
        CREATE INDEX idx_log_events_level         ON audit.log_events (level);
        CREATE INDEX idx_log_events_user_id       ON audit.log_events (user_id);

        GRANT INSERT ON audit.log_events TO app;
        EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE partman_user IN SCHEMA audit GRANT INSERT ON TABLES TO app';

        PERFORM partman.create_parent(
          p_parent_table => 'audit.log_events',
          p_control      => 'created_at',
          p_interval     => '1 week',
          p_premake      => 3
        );
    END IF;
END $$;

COMMIT;
