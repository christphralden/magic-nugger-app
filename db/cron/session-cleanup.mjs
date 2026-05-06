#!/usr/bin/env node
import { Client } from "pg";

const olderThanMs = parseInt(
  process.env.GAME_SESSION_RESUME_WINDOW_MS ?? "1800000",
  10,
);
const host = process.env.POSTGRES_HOST ?? "localhost";
const connectionString = `postgresql://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${host}:5432/${process.env.POSTGRES_DB}`;

async function main() {
  const client = new Client({ connectionString });
  await client.connect();
  const start = Date.now();
  try {
    const { rowCount } = await client.query(
      `UPDATE game_sessions
       SET status = 'abandoned', ended_at = now()
       WHERE status = 'in_progress'
         AND started_at < now() - ($1 || ' milliseconds')::interval`,
      [olderThanMs],
    );
    const count = rowCount ?? 0;
    await client.query(
      "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
      [
        "cron:session-cleanup",
        "info",
        JSON.stringify({ count, duration_ms: Date.now() - start }),
      ],
    );
    if (count > 0) {
      console.log(`[session-cleanup] abandoned ${count} orphaned session(s)`);
    }
  } catch (err) {
    await client
      .query(
        "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
        [
          "cron:session-cleanup",
          "error",
          JSON.stringify({ error: err.message }),
        ],
      )
      .catch(() => {});
    throw err;
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error("[session-cleanup] error:", err.message);
  process.exit(1);
});
