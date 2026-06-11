#!/usr/bin/env node
import { Client } from "pg";

const olderThanMs = parseInt(
  process.env.GAME_SESSION_RESUME_WINDOW_MS ?? "1800000",
  10,
);
const BATCH_SIZE = parseInt(
  process.env.SESSION_CLEANUP_BATCH_SIZE ?? "100",
  10,
);
const source = process.stdout.isTTY ? "manual" : "cron";
const host = process.env.POSTGRES_HOST ?? "localhost";
const connectionString = `postgresql://${encodeURIComponent(process.env.APP_USER)}:${encodeURIComponent(process.env.APP_USER_PASSWORD)}@${host}:5432/${process.env.POSTGRES_DB}`;

async function resolveRoomsForAbandonedSessions(client, roomIds) {
  if (roomIds.length === 0) return 0;

  const uniqueIds = [...new Set(roomIds)];
  let resolvedCount = 0;

  for (let i = 0; i < uniqueIds.length; i += BATCH_SIZE) {
    const batch = uniqueIds.slice(i, i + BATCH_SIZE);
    const { rows } = await client.query(
      `WITH completable AS (
         SELECT r.id
         FROM rooms r
         WHERE r.id = ANY($1)
           AND r.status = 'in_progress'
           AND NOT EXISTS (
             SELECT 1
             FROM room_members rm
             LEFT JOIN game_sessions gs ON gs.id = rm.game_session_id
             WHERE rm.room_id = r.id
               AND (rm.game_session_id IS NULL OR gs.status = 'in_progress')
           )
       )
       UPDATE rooms
       SET status = 'completed', ended_at = now(), updated_at = now()
       WHERE id IN (SELECT id FROM completable)
       RETURNING id`,
      [batch],
    );
    resolvedCount += rows.length;
  }

  return resolvedCount;
}

async function main() {
  const client = new Client({ connectionString });
  await client.connect();
  const start = Date.now();
  try {
    await client.query("BEGIN");

    const { rows } = await client.query(
      `WITH abandoned AS (
         UPDATE game_sessions
         SET status = 'abandoned',
             ended_at = now(),
             elo_after = GREATEST(0, elo_before + COALESCE(elo_delta, 0))
         WHERE status = 'in_progress'
           AND started_at < now() - ($1 || ' milliseconds')::interval
           AND elo_after IS NULL
         RETURNING
           id,
           player_id,
           room_id,
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
       SELECT id, room_id FROM abandoned`,
      [olderThanMs],
    );

    await client.query("COMMIT");

    const sessionIds = rows.map((r) => r.id);
    const sessionCount = sessionIds.length;

    const roomIds = rows
      .filter((r) => r.room_id !== null)
      .map((r) => r.room_id);
    const resolvedRoomCount = await resolveRoomsForAbandonedSessions(
      client,
      roomIds,
    );

    await client.query(
      "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
      [
        "cron:game-session-cleanup",
        "info",
        JSON.stringify({
          source,
          count: sessionCount,
          session_ids: sessionIds,
          rooms_resolved: resolvedRoomCount,
          duration_ms: Date.now() - start,
        }),
      ],
    );

    if (sessionCount > 0) {
      console.log(
        `[game-session-cleanup] abandoned ${sessionCount} orphaned session(s)`,
      );
    }
    if (resolvedRoomCount > 0) {
      console.log(
        `[game-session-cleanup] resolved ${resolvedRoomCount} room(s) to completed`,
      );
    }
  } catch (err) {
    await client.query("ROLLBACK").catch(() => {});
    await client
      .query(
        "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
        [
          "cron:game-session-cleanup",
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
  console.error("[game-session-cleanup] error:", err.message);
  process.exit(1);
});
