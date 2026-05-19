BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605100004_add_room_permissions',
      ARRAY[
        '202605020001_create_permissions',
        '202605020003_create_role_permissions'
      ],
      'Add room permissions and grant to student and teacher roles'
    ) INTO patch_registered;

    IF patch_registered THEN
        INSERT INTO permissions (name) VALUES
          ('room:create'),
          ('room:join'),
          ('room:start'),
          ('room:end'),
          ('room:cancel');

        INSERT INTO role_permissions (role_id, permission_id)
        SELECT r.id, p.id
        FROM roles r
        CROSS JOIN permissions p
        WHERE r.name = 'student'
          AND p.name IN ('room:create', 'room:join', 'room:start', 'room:end', 'room:cancel');

        INSERT INTO role_permissions (role_id, permission_id)
        SELECT r.id, p.id
        FROM roles r
        CROSS JOIN permissions p
        WHERE r.name = 'teacher'
          AND p.name IN ('room:create', 'room:join', 'room:start', 'room:end', 'room:cancel');
    END IF;
END $$;

COMMIT;
