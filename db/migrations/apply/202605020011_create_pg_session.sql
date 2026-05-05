BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202605020011_create_pg_session',
      NULL,
      'Create connect-pg-simple session store table'
    ) INTO patch_registered;

    IF patch_registered THEN
        CREATE TABLE "session" (
          "sid"    varchar      NOT NULL COLLATE "default",
          "sess"   json         NOT NULL,
          "expire" timestamp(6) NOT NULL
        );

        ALTER TABLE "session" ADD CONSTRAINT "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE;

        CREATE INDEX "IDX_session_expire" ON "session" ("expire");
    END IF;
END $$;

COMMIT;
