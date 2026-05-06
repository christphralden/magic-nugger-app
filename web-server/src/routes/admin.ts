import { Router } from "express";
import { z } from "zod";
import { db } from "@/db/client";
import { authenticate } from "@/middleware/authenticate";
import { authorize } from "@/middleware/authorize";
import { validate } from "@/middleware/validate";
import { parsePagination } from "@/utils/pagination";
import { RequestAdjustEloSchema, ErrorCode } from "@magic-nugger-app/shared";
import { leaderboardService } from "@/services/leaderboard.service";
import type {
  ApiResponse,
  Player,
  GameSession,
  PaginatedData,
} from "@magic-nugger-app/shared";

export const adminRouter = Router();

adminRouter.use(authenticate, authorize("admin:full"));

adminRouter.get("/players", async (req, res) => {
  const { cursor, limit } = parsePagination(req.query);
  const { rows } = await db.query<Player>(
    `SELECT id, username, display_name, email, role_id, current_elo, created_at
     FROM players
     WHERE ($1::bigint IS NULL OR EXTRACT(EPOCH FROM created_at)*1000 < $1)
     ORDER BY created_at DESC
     LIMIT $2`,
    [cursor ?? null, limit],
  );
  const next_cursor =
    rows.length === limit
      ? new Date(rows[rows.length - 1].created_at).getTime()
      : null;
  res.json({
    code: 200,
    error: null,
    data: { items: rows, next_cursor },
  } satisfies ApiResponse<PaginatedData<Player>>);
});

adminRouter.patch(
  "/players/:id/role",
  validate(z.object({ role: z.string() })),
  async (req, res) => {
    const { rows } = await db.query(
      `UPDATE players SET role_id = (SELECT id FROM roles WHERE name = $2), updated_at = now() WHERE id = $1 RETURNING id`,
      [req.params.id, req.body.role],
    );
    if (!rows[0]) {
      return res.status(404).json({
        code: ErrorCode.NOT_FOUND,
        error: "Player not found",
        data: null,
      } satisfies ApiResponse<null>);
    }
    res.json({
      code: 200,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);

adminRouter.patch(
  "/players/:id/elo",
  validate(RequestAdjustEloSchema),
  async (req, res) => {
    const { elo } = req.body;
    const { rows: playerRows } = await db.query<{ current_elo: number }>(
      `SELECT current_elo FROM players WHERE id = $1`,
      [req.params.id],
    );
    if (!playerRows[0]) {
      return res.status(404).json({
        code: ErrorCode.NOT_FOUND,
        error: "Player not found",
        data: null,
      } satisfies ApiResponse<null>);
    }

    const before = playerRows[0].current_elo;
    const after = elo;
    const delta = after - before;

    await db.query(
      `UPDATE players SET current_elo = $2, updated_at = now() WHERE id = $1`,
      [req.params.id, after],
    );

    await db.query(
      `INSERT INTO elo_history (player_id, elo_before, elo_after, delta, reason)
       VALUES ($1, $2, $3, $4, $5)`,
      [req.params.id, before, after, delta, "admin_adjustment"],
    );

    leaderboardService.invalidateGlobal();
    res.json({
      code: 200,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);

adminRouter.get("/game-sessions/active", async (_req, res) => {
  // no pagination needed since bounded to active sessions
  const { rows } = await db.query<GameSession>(
    `SELECT * FROM game_sessions
     WHERE status = 'in_progress'
     ORDER BY started_at DESC
     LIMIT 100`,
  );
  res.json({
    code: 200,
    error: null,
    data: rows,
  } satisfies ApiResponse<GameSession[]>);
});

adminRouter.get("/game-sessions", async (req, res) => {
  const { player_id, level_id, status } = req.query;
  const { cursor, limit } = parsePagination(req.query);
  const conditions: string[] = [];
  const values: unknown[] = [];
  let idx = 1;

  if (player_id) {
    conditions.push(`player_id = $${idx++}`);
    values.push(player_id);
  }
  if (level_id) {
    conditions.push(`level_id = $${idx++}`);
    values.push(level_id);
  }
  if (status) {
    conditions.push(`status = $${idx++}`);
    values.push(status);
  }
  if (cursor !== undefined) {
    conditions.push(`EXTRACT(EPOCH FROM started_at)*1000 < $${idx++}::bigint`);
    values.push(cursor);
  }

  const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  values.push(limit);
  const { rows } = await db.query<GameSession>(
    `SELECT * FROM game_sessions ${where} ORDER BY started_at DESC LIMIT $${idx}`,
    values,
  );
  const next_cursor =
    rows.length === limit
      ? new Date(rows[rows.length - 1].started_at).getTime()
      : null;
  res.json({
    code: 200,
    error: null,
    data: { items: rows, next_cursor },
  } satisfies ApiResponse<PaginatedData<GameSession>>);
});

adminRouter.get("/stats", async (_req, res) => {
  const { rows } = await db.query<{
    total_players: number;
    total_sessions: number;
    completed_sessions: number;
  }>(
    `SELECT
      (SELECT COUNT(*) FROM players) as total_players,
      (SELECT COUNT(*) FROM game_sessions) as total_sessions,
      (SELECT COUNT(*) FROM game_sessions WHERE status = 'completed') as completed_sessions`,
  );
  res.json({
    code: 200,
    error: null,
    data: rows[0],
  } satisfies ApiResponse<{
    total_players: number;
    total_sessions: number;
    completed_sessions: number;
  }>);
});
