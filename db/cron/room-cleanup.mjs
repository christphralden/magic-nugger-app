#!/usr/bin/env node
import { Client } from "pg";

const WAITING_TIMEOUT_MS = parseInt(
  process.env.ROOM_WAITING_TIMEOUT_MS ?? "7200000",
  10,
);
const IN_PROGRESS_TIMEOUT_MS = parseInt(
  process.env.ROOM_IN_PROGRESS_TIMEOUT_MS ?? "14400000",
  10,
);
const source = process.stdout.isTTY ? "manual" : "cron";
const host = process.env.POSTGRES_HOST ?? "localhost";
const connectionString = `postgresql://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${host}:5432/${process.env.POSTGRES_DB}`;

async function main() {
  const client = new Client({ connectionString });
  await client.connect();
  const start = Date.now();
  try {
    await client.query("BEGIN");

    const { rows } = await client.query(
      `UPDATE rooms
       SET status = 'cancelled', ended_at = now(), updated_at = now()
       WHERE
         (status = 'waiting'      AND created_at  < now() - ($1 || ' milliseconds')::interval)
         OR
         (status = 'in_progress'  AND started_at  < now() - ($2 || ' milliseconds')::interval)
       RETURNING id, status`,
      [WAITING_TIMEOUT_MS, IN_PROGRESS_TIMEOUT_MS],
    );

    await client.query("COMMIT");

    const count = rows.length;
    await client.query(
      "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
      [
        "cron:room-cleanup",
        "info",
        JSON.stringify({
          source,
          count,
          room_ids: rows.map((r) => r.id),
          duration_ms: Date.now() - start,
        }),
      ],
    );
    if (count > 0) {
      console.log(`[room-cleanup] cancelled ${count} stale room(s)`);
    }
  } catch (err) {
    await client.query("ROLLBACK").catch(() => {});
    await client
      .query(
        "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
        [
          "cron:room-cleanup",
          "error",
          JSON.stringify({ source, error: err.message }),
        ],
      )
      .catch(() => {});
    throw err;
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error("[room-cleanup] error:", err.message);
  process.exit(1);
});
