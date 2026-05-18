#!/usr/bin/env node
import { Client } from "pg";

const WAITING_TIMEOUT_MS = parseInt(process.env.ROOM_WAITING_TIMEOUT_MS ?? "300000", 10);
const IN_PROGRESS_TIMEOUT_MS = parseInt(process.env.ROOM_IN_PROGRESS_TIMEOUT_MS ?? "600000", 10);
const BATCH_SIZE = parseInt(process.env.ROOM_CLEANUP_BATCH_SIZE ?? "50", 10);
const source = process.stdout.isTTY ? "manual" : "cron";
const host = process.env.POSTGRES_HOST ?? "localhost";
const connectionString = `postgresql://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${host}:5432/${process.env.POSTGRES_DB}`;

async function cancelStaleWaitingRooms(client) {
  const { rows } = await client.query(
    `UPDATE rooms
     SET status = 'cancelled', ended_at = now(), updated_at = now()
     WHERE status = 'waiting'
       AND created_at < now() - ($1 || ' milliseconds')::interval
     RETURNING id`,
    [WAITING_TIMEOUT_MS],
  );
  const ids = rows.map((r) => r.id);
  if (ids.length > 0) {
    await client.query(
      `UPDATE room_members SET deleted_at = now()
       WHERE room_id = ANY($1) AND deleted_at IS NULL`,
      [ids],
    );
  }
  return ids;
}

async function completeStaleInProgressRooms(client, start) {
  const completedRoomIds = [];
  const totalAbandoned = [];

  while (true) {
    const { rows: staleRooms } = await client.query(
      `SELECT id FROM rooms
       WHERE status = 'in_progress'
         AND started_at < now() - ($1 || ' milliseconds')::interval
       LIMIT $2`,
      [IN_PROGRESS_TIMEOUT_MS, BATCH_SIZE],
    );
    if (staleRooms.length === 0) break;

    const roomIds = staleRooms.map((r) => r.id);

    await client.query("BEGIN");
    try {
      const { rows: abandoned } = await client.query(
        `WITH abandoned AS (
           UPDATE game_sessions
           SET status = 'abandoned',
               ended_at = now(),
               elo_after = GREATEST(0, elo_before + COALESCE(elo_delta, 0))
           WHERE room_id = ANY($1)
             AND status = 'in_progress'
             AND elo_after IS NULL
           RETURNING
             id,
             player_id,
             elo_before,
             COALESCE(elo_delta, 0) AS delta,
             GREATEST(0, elo_before + COALESCE(elo_delta, 0)) AS elo_after
         ),
         history AS (
           INSERT INTO elo_history (player_id, session_id, elo_before, elo_after, delta, reason)
           SELECT player_id, id, elo_before, elo_after, delta, 'session_abandoned'
           FROM abandoned
         ),
         player_update AS (
           UPDATE players p
           SET current_elo = GREATEST(0, p.current_elo + a.delta),
               updated_at = now()
           FROM abandoned a
           WHERE p.id = a.player_id AND a.delta != 0
         )
         SELECT id FROM abandoned`,
        [roomIds],
      );

      const { rows: completed } = await client.query(
        `UPDATE rooms
         SET status = 'completed', ended_at = now(), updated_at = now()
         WHERE id = ANY($1) AND status = 'in_progress'
         RETURNING id`,
        [roomIds],
      );

      const completedIds = completed.map((r) => r.id);
      if (completedIds.length > 0) {
        await client.query(
          `UPDATE room_members SET deleted_at = now()
           WHERE room_id = ANY($1) AND deleted_at IS NULL`,
          [completedIds],
        );
      }

      await client.query("COMMIT");
      totalAbandoned.push(...abandoned.map((r) => r.id));
      completedRoomIds.push(...completed.map((r) => r.id));
    } catch (err) {
      await client.query("ROLLBACK").catch(() => {});
      throw err;
    }

    if (staleRooms.length < BATCH_SIZE) break;
  }

  return { completedRoomIds, abandonedSessionCount: totalAbandoned.length };
}

async function main() {
  const client = new Client({ connectionString });
  await client.connect();
  const start = Date.now();
  try {
    const cancelledIds = await cancelStaleWaitingRooms(client);
    const { completedRoomIds, abandonedSessionCount } = await completeStaleInProgressRooms(client, start);

    const summary = {
      source,
      cancelled_waiting: cancelledIds.length,
      cancelled_ids: cancelledIds,
      completed_in_progress: completedRoomIds.length,
      completed_ids: completedRoomIds,
      sessions_abandoned: abandonedSessionCount,
      duration_ms: Date.now() - start,
    };

    await client.query(
      "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
      ["cron:room-cleanup", "info", JSON.stringify(summary)],
    );

    if (cancelledIds.length > 0) {
      console.log(`[room-cleanup] cancelled ${cancelledIds.length} stale waiting room(s)`);
    }
    if (completedRoomIds.length > 0) {
      console.log(`[room-cleanup] completed ${completedRoomIds.length} stuck in-progress room(s), abandoned ${abandonedSessionCount} session(s)`);
    }
  } catch (err) {
    await client
      .query(
        "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
        ["cron:room-cleanup", "error", JSON.stringify({ source, error: err.message })],
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
