-- Create audit events to log every endpoint activity
BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020012_create_audit_events',
      ARRAY['202605020004_create_players'],
      'Create audit schema and partitioned audit events table'
    ) INTO patch_registered;

    IF patch_registered THEN
        GRANT USAGE ON SCHEMA partman TO partman_user;
        GRANT ALL ON ALL TABLES IN SCHEMA partman TO partman_user;
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA partman TO partman_user;
        GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA partman TO partman_user;
        EXECUTE format('GRANT TEMPORARY ON DATABASE %I TO partman_user', current_database());

        CREATE SCHEMA audit;
        GRANT ALL ON SCHEMA audit TO partman_user;
        GRANT USAGE ON SCHEMA audit TO app;

        CREATE TABLE audit.audit_events (
          id          UUID         NOT NULL DEFAULT gen_random_uuid(),
          user_id     UUID         REFERENCES players(id) ON DELETE SET NULL,
          url         VARCHAR(255) NOT NULL,
          status_code SMALLINT     NOT NULL,
          ip_address  INET,
          user_agent  TEXT,
          metadata    JSONB,
          created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
        ) PARTITION BY RANGE (created_at);

        ALTER TABLE audit.audit_events ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id, created_at);
        ALTER TABLE audit.audit_events OWNER TO partman_user;

        CREATE INDEX idx_audit_events_user_id     ON audit.audit_events (user_id);
        CREATE INDEX idx_audit_events_created_at  ON audit.audit_events (created_at DESC);
        CREATE INDEX idx_audit_events_url         ON audit.audit_events (url);
        CREATE INDEX idx_audit_events_status_code ON audit.audit_events (status_code);

        GRANT INSERT ON audit.audit_events TO app;
        EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE partman_user IN SCHEMA audit GRANT INSERT ON TABLES TO app';

        PERFORM partman.create_parent(
          p_parent_table => 'audit.audit_events',
          p_control      => 'created_at',
          p_interval     => '1 month',
          p_premake      => 3
        );
    END IF;
END $$;

COMMIT;
