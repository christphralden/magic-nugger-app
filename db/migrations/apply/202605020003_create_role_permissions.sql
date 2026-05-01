DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020003_create_role_permissions',
      ARRAY[
        '202605020001_create_permissions',
        '202605020002_create_roles'
      ], 
      'Create role_permissions join table and seed') 
    INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE role_permissions (
          role_id       INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
          permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
          PRIMARY KEY (role_id, permission_id)
        );

        INSERT INTO role_permissions (role_id, permission_id)
        SELECT r.id, p.id
        FROM roles r
        CROSS JOIN permissions p
        WHERE r.name = 'student'
          AND p.name IN (
            'player:read',
            'player:update',
            'session:create',
            'session:update',
            'classroom:join',
            'classroom:leave',
            'leaderboard:read'
          );

        INSERT INTO role_permissions (role_id, permission_id)
        SELECT r.id, p.id
        FROM roles r
        CROSS JOIN permissions p
        WHERE r.name = 'teacher'
          AND p.name IN (
            'player:read',
            'player:update',
            'session:create',
            'session:update',
            'classroom:create',
            'classroom:update',
            'classroom:delete',
            'classroom:read',
            'leaderboard:read'
          );

        INSERT INTO role_permissions (role_id, permission_id)
        SELECT r.id, p.id
        FROM roles r
        CROSS JOIN permissions p
        WHERE r.name = 'admin'
          AND p.name IN (
            '*', 
            'admin:full'
          );
    END IF;
END $$;
