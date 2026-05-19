BEGIN;
DELETE FROM role_permissions
WHERE permission_id IN (
  SELECT id FROM permissions
  WHERE name IN ('room:create', 'room:join', 'room:start', 'room:end', 'room:cancel')
);
DELETE FROM permissions
WHERE name IN ('room:create', 'room:join', 'room:start', 'room:end', 'room:cancel');
SELECT _v.unregister_patch('202605100004_add_room_permissions');
COMMIT;
