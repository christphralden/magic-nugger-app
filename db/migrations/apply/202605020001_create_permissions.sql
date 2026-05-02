BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020001_create_permissions',
      ARRAY['202605020000_patch_infrastructure'], 
      'Create permissions table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE permissions (
          id   SERIAL      PRIMARY KEY,
          name VARCHAR(64) NOT NULL UNIQUE
        );

        INSERT INTO permissions (name) VALUES
          ('player:read'),
          ('player:update'),
          ('session:create'),
          ('session:update'),
          ('classroom:create'),
          ('classroom:update'),
          ('classroom:delete'),
          ('classroom:read'),
          ('classroom:join'),
          ('classroom:leave'),
          ('leaderboard:read'),
          ('level:create'),
          ('level:update'),
          ('level:delete'),
          ('admin:full'),
          ('*');
    END IF;
END $$;

COMMIT;
