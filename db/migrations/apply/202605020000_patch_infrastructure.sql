BEGIN;

CREATE SCHEMA IF NOT EXISTS _v;

CREATE TABLE IF NOT EXISTS _v.patches (
  id           SERIAL       PRIMARY KEY,
  patch_name   VARCHAR(255) NOT NULL UNIQUE,
  dependencies TEXT[],
  description  TEXT,
  applied_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION _v.try_register_patch(
  patch_name TEXT,
  dependencies TEXT[] DEFAULT NULL,
  description TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
  dep TEXT;
BEGIN
  IF EXISTS (SELECT 1 FROM _v.patches WHERE patches.patch_name = $1) THEN
    RETURN false;
  END IF;

  IF dependencies IS NOT NULL THEN
    FOREACH dep IN ARRAY dependencies LOOP
      IF NOT EXISTS (SELECT 1 FROM _v.patches WHERE patches.patch_name = dep) THEN
        RAISE EXCEPTION 'Missing dependency: %', dep;
      END IF;
    END LOOP;
  END IF;

  INSERT INTO _v.patches (patch_name, dependencies, description)
  VALUES ($1, $2, $3);
  RETURN true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _v.unregister_patch(patch_name TEXT)
RETURNS void AS $$
BEGIN
  DELETE FROM _v.patches WHERE patches.patch_name = $1;
END;
$$ LANGUAGE plpgsql;

INSERT INTO _v.patches (patch_name, dependencies, description)
VALUES ('202605020000_patch_infrastructure', NULL, 'Patch tracking infrastructure')
ON CONFLICT DO NOTHING;

COMMIT;
