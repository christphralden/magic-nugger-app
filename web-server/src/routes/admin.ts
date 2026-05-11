import { Router } from "express";
import { z } from "zod";
import { authenticate, getUser } from "@/middleware/authenticate";
import { authorize } from "@/middleware/authorize";
import { validate } from "@/middleware/validate";
import { parsePagination } from "@/utils/pagination";
import { RequestAdjustEloSchema, HttpCode } from "@magic-nugger-app/shared";
import { leaderboardService } from "@/services/leaderboard.service";
import { loggingService } from "@/services/logging.service";
import type {
  ApiResponse,
  Player,
  GameSession,
  PaginatedData,
} from "@magic-nugger-app/shared";
import { getDb, tx } from "@/db/transaction-context";

export const adminRouter = Router();

adminRouter.use(authenticate, authorize("admin:full"));

adminRouter.get("/players", async (req, res) => {
  const admin = getUser(req);
  const { cursor, limit } = parsePagination(req.query);
  const { rows } = await getDb().query<Player & { role_name: string }>(
    `SELECT p.id, p.username, p.display_name, p.email, r.name AS role_name, p.current_elo, p.created_at
     FROM players p
     JOIN roles r ON p.role_id = r.id
     WHERE ($1::bigint IS NULL OR EXTRACT(EPOCH FROM p.created_at)*1000 < $1)
     ORDER BY p.created_at DESC
     LIMIT $2`,
    [cursor ?? null, limit],
  );
  const next_cursor =
    rows.length === limit
      ? String(new Date(rows[rows.length - 1].created_at).getTime())
      : null;
  loggingService.log({
    event: "admin:player_viewed",
    level: "info",
    userId: admin.id,
  });
  res.json({
    code: HttpCode.OK,
    error: null,
    data: { items: rows, next_cursor },
  } satisfies ApiResponse<PaginatedData<Player>>);
});

adminRouter.patch(
  "/players/:id/role",
  validate(z.object({ role: z.string() })),
  async (req, res) => {
    const admin = getUser(req);
    const { rows } = await getDb().query(
      `UPDATE players SET role_id = (SELECT id FROM roles WHERE name = $2), updated_at = now() WHERE id = $1 RETURNING id`,
      [req.params.id, req.body.role],
    );
    if (!rows[0]) {
      return res.status(HttpCode.NOT_FOUND).json({
        code: HttpCode.NOT_FOUND,
        error: "Player not found",
        data: null,
      } satisfies ApiResponse<null>);
    }
    loggingService.log({
      event: "admin:role_changed",
      level: "info",
      userId: admin.id,
      metadata: { target_player_id: req.params.id, new_role: req.body.role },
    });
    res.json({
      code: HttpCode.OK,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);

adminRouter.patch(
  "/players/:id/elo",
  validate(RequestAdjustEloSchema),
  async (req, res) => {
    const admin = getUser(req);
    const { elo } = req.body;
    const { rows: playerRows } = await getDb().query<{ current_elo: number }>(
      `SELECT current_elo FROM players WHERE id = $1`,
      [req.params.id],
    );
    if (!playerRows[0]) {
      return res.status(HttpCode.NOT_FOUND).json({
        code: HttpCode.NOT_FOUND,
        error: "Player not found",
        data: null,
      } satisfies ApiResponse<null>);
    }

    const before = playerRows[0].current_elo;
    const after = elo;
    const delta = after - before;

    tx(async () => {
      await Promise.all([
        await getDb().query(
          `UPDATE players SET current_elo = $2, updated_at = now() WHERE id = $1`,
          [req.params.id, after],
        ),

        await getDb().query(
          `INSERT INTO elo_history (player_id, elo_before, elo_after, delta, reason)
       VALUES ($1, $2, $3, $4, $5)`,
          [req.params.id, before, after, delta, "admin_adjustment"],
        ),
      ]);
    });

    leaderboardService.invalidateGlobal();
    loggingService.log({
      event: "admin:elo_adjusted",
      level: "info",
      userId: admin.id,
      metadata: { target_player_id: req.params.id, before, after, delta },
    });
    loggingService.log({
      event: "elo:admin_adjusted",
      level: "info",
      userId: req.params.id,
      metadata: { adjusted_by: admin.id, before, after, delta },
    });
    res.json({
      code: HttpCode.OK,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);

adminRouter.get("/game-sessions/active", async (req, res) => {
  const admin = getUser(req);
  const { rows } = await getDb().query<GameSession>(
    `SELECT * FROM game_sessions
     WHERE status = 'in_progress'
     ORDER BY started_at DESC
     LIMIT 100`,
  );
  loggingService.log({
    event: "admin:sessions_viewed",
    level: "info",
    userId: admin.id,
    metadata: { filter: "active" },
  });
  res.json({
    code: HttpCode.OK,
    error: null,
    data: rows,
  } satisfies ApiResponse<GameSession[]>);
});

adminRouter.get("/game-sessions", async (req, res) => {
  const admin = getUser(req);
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
  const { rows } = await getDb().query<GameSession>(
    `SELECT * FROM game_sessions ${where} ORDER BY started_at DESC LIMIT $${idx}`,
    values,
  );
  const next_cursor =
    rows.length === limit
      ? String(new Date(rows[rows.length - 1].started_at).getTime())
      : null;
  loggingService.log({
    event: "admin:sessions_viewed",
    level: "info",
    userId: admin.id,
    metadata: { filter: { player_id, level_id, status } },
  });
  res.json({
    code: HttpCode.OK,
    error: null,
    data: { items: rows, next_cursor },
  } satisfies ApiResponse<PaginatedData<GameSession>>);
});

adminRouter.get("/stats", async (_req, res) => {
  const { rows } = await getDb().query<{
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
    code: HttpCode.OK,
    error: null,
    data: rows[0],
  } satisfies ApiResponse<{
    total_players: number;
    total_sessions: number;
    completed_sessions: number;
  }>);
});
