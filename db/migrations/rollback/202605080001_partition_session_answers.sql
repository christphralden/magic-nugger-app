BEGIN;
SELECT _v.unregister_patch('202605080001_partition_session_answers');

CREATE TEMP TABLE _bak_session_answers AS SELECT * FROM session_answers;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM partman.part_config WHERE parent_table = 'public.session_answers') THEN
    PERFORM partman.config_cleanup('public.session_answers');
  END IF;
END $$;
DROP TABLE IF EXISTS partman.template_public_session_answers;
DROP TABLE session_answers CASCADE;

CREATE TABLE session_answers (
  id            BIGSERIAL   PRIMARY KEY,
  session_id    UUID        NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
  is_correct    BOOLEAN     NOT NULL,
  elo_delta     INTEGER     NOT NULL,
  time_taken_ms INTEGER,
  answered_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_answers_session ON session_answers (session_id, answered_at);

INSERT INTO session_answers SELECT * FROM _bak_session_answers;
SELECT setval('session_answers_id_seq', COALESCE((SELECT MAX(id) FROM session_answers), 1));

COMMIT;
