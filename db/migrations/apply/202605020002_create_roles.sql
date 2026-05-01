DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020002_create_roles',
      ARRAY['202605020000_patch_infrastructure'], 
      'Create roles table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE roles (
          id          SERIAL      PRIMARY KEY,
          name        VARCHAR(32) NOT NULL UNIQUE,
          description TEXT
        );

        INSERT INTO roles (name, description) VALUES
          ('student', 'Default student role'),
          ('teacher', 'Teacher role'),
          ('admin',   'Admin with full access');
    END IF;
END $$;
