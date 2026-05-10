BEGIN;
SELECT _v.unregister_patch('202605080002_partition_elo_history');

CREATE TEMP TABLE _bak_elo_history AS SELECT * FROM elo_history;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM partman.part_config WHERE parent_table = 'public.elo_history') THEN
    PERFORM partman.config_cleanup('public.elo_history');
  END IF;
END $$;
DROP TABLE IF EXISTS partman.template_public_elo_history;
DROP TABLE elo_history CASCADE;

CREATE TABLE elo_history (
  id          BIGSERIAL   PRIMARY KEY,
  player_id   UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  session_id  UUID        REFERENCES game_sessions(id) ON DELETE SET NULL,
  elo_before  INTEGER     NOT NULL,
  elo_after   INTEGER     NOT NULL,
  delta       INTEGER     NOT NULL,
  reason      VARCHAR(32) NOT NULL
              CHECK (reason IN ('session_completed', 'session_failed', 'admin_adjustment', 'decay')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_elo_history_player ON elo_history (player_id, created_at DESC);

INSERT INTO elo_history SELECT * FROM _bak_elo_history;
SELECT setval('elo_history_id_seq', COALESCE((SELECT MAX(id) FROM elo_history), 1));

COMMIT;
