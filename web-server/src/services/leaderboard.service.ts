import { getDb } from "@/db/transaction-context.js";
import { leaderboardCache } from "@/cache/leaderboard.cache.js";
import { buildCacheKey, buildInvalidationPrefix } from "@/cache/cache-key.js";
import { periodToStartDate } from "@/utils/period.js";
import type {
  CursorPagination,
  PaginatedData,
  LeaderboardPeriod,
  GlobalLeaderboardRow,
  LevelLeaderboardRow,
  RoomLeaderboardRow,
} from "@magic-nugger-app/shared";
import { loggingService } from "./logging.service";

function parseCompoundCursor(
  cursor: string | undefined,
): [number | null, string | null] {
  if (!cursor) return [null, null];
  const sep = cursor.lastIndexOf(":");
  if (sep === -1) return [null, null];
  const value = parseInt(cursor.slice(0, sep));
  const id = cursor.slice(sep + 1);
  return [isNaN(value) ? null : value, id || null];
}

export const leaderboardService = {
  async getGlobal(
    pagination: CursorPagination,
  ): Promise<PaginatedData<GlobalLeaderboardRow>> {
    const key = buildCacheKey({
      table: "leaderboard",
      identity: { scope: "global" },
      pagination,
    });
    const cached = leaderboardCache.get(key);
    if (cached) {
      console.log(`[cache] hit ${key}`);
      return cached as PaginatedData<GlobalLeaderboardRow>;
    }

    console.log(`[cache] miss ${key}`);
    loggingService.log({
      event: "cache:miss",
      level: "info",
      description: key,
    });

    const [cursorElo, cursorId] = parseCompoundCursor(pagination.cursor);
    const { rows } = await getDb().query<GlobalLeaderboardRow>(
      `SELECT
         p.id AS player_id, p.username, p.display_name, p.avatar_url, p.current_elo,
         COALESCE(MAX(gs.max_streak), 0) AS max_streak
       FROM players p
       LEFT JOIN game_sessions gs ON gs.player_id = p.id AND gs.status = 'completed'
       WHERE ($1::int IS NULL OR p.current_elo < $1 OR (p.current_elo = $1 AND p.id > $2))
       GROUP BY p.id, p.username, p.display_name, p.avatar_url, p.current_elo
       ORDER BY p.current_elo DESC, p.id ASC
       LIMIT $3`,
      [cursorElo, cursorId, pagination.limit],
    );
    const last = rows[rows.length - 1];
    const next_cursor =
      rows.length === pagination.limit
        ? `${last.current_elo}:${last.player_id}`
        : null;
    const result: PaginatedData<GlobalLeaderboardRow> = {
      items: rows,
      next_cursor,
    };
    leaderboardCache.set(key, result);
    return result;
  },

  async getByLevel(
    levelId: number,
    pagination: CursorPagination,
    period: LeaderboardPeriod,
  ): Promise<PaginatedData<LevelLeaderboardRow>> {
    const key = buildCacheKey({
      table: "leaderboard",
      identity: { levelId, scope: "level", period },
      pagination,
    });
    const cached = leaderboardCache.get(key);
    if (cached) {
      console.log(`[cache] hit ${key}`);
      return cached as PaginatedData<LevelLeaderboardRow>;
    }
    console.log(`[cache] miss ${key}`);
    loggingService.log({
      event: "cache:miss",
      level: "info",
      description: key,
    });

    const [cursorScore, cursorPlayerId] = parseCompoundCursor(
      pagination.cursor,
    );
    const { rows } = await getDb().query<LevelLeaderboardRow>(
      `SELECT
         gs.player_id, p.username, p.display_name, p.avatar_url,
         MAX(gs.score) AS best_score,
         MAX(gs.max_streak) AS max_streak
       FROM game_sessions gs
       JOIN players p ON p.id = gs.player_id
       WHERE gs.level_id = $1
         AND gs.status = 'completed'
         AND ($4::timestamptz IS NULL OR gs.ended_at >= $4)
       GROUP BY gs.player_id, p.username, p.display_name, p.avatar_url
       HAVING ($2::int IS NULL OR MAX(gs.score) < $2 OR (MAX(gs.score) = $2 AND gs.player_id > $3))
       ORDER BY best_score DESC, gs.player_id ASC
       LIMIT $5`,
      [
        levelId,
        cursorScore,
        cursorPlayerId,
        periodToStartDate(period),
        pagination.limit,
      ],
    );
    const last = rows[rows.length - 1];
    const next_cursor =
      rows.length === pagination.limit
        ? `${last.best_score}:${last.player_id}`
        : null;
    const result: PaginatedData<LevelLeaderboardRow> = {
      items: rows,
      next_cursor,
    };
    leaderboardCache.set(key, result);
    return result;
  },

  async getByRoom(roomId: string): Promise<RoomLeaderboardRow[]> {
    const { rows } = await getDb().query<RoomLeaderboardRow>(
      `SELECT
        rm.player_id,
        p.username,
        p.display_name,
        p.avatar_url,
        rm.game_session_id,
        gs.correct_count,
        gs.incorrect_count,
        gs.max_streak,
        gs.status          AS session_status,
        gs.ended_at        AS finished_at
       FROM room_members rm
       JOIN players p ON p.id = rm.player_id
       JOIN rooms r ON r.id = rm.room_id
       LEFT JOIN game_sessions gs ON gs.id = rm.game_session_id
       WHERE rm.room_id = $1
         AND rm.player_id != r.host_id
         AND (rm.deleted_at IS NULL OR (r.started_at IS NOT NULL AND rm.deleted_at > r.started_at))
       ORDER BY
         CASE WHEN gs.status IN ('completed', 'failed') THEN 0 ELSE 1 END,
         gs.score DESC NULLS LAST,
         rm.joined_at ASC`,
      [roomId],
    );
    return rows;
  },

  invalidateGlobal(): void {
    const prefix = buildInvalidationPrefix({
      table: "leaderboard",
      identity: { scope: "global" },
    });

    console.log(`[cache] pruned ${prefix}`);
    loggingService.log({
      event: "cache:pruned",
      level: "info",
      description: prefix,
    });
    leaderboardCache.deleteByPrefix(prefix);
  },

  invalidateByLevel(levelId: number): void {
    const prefix = buildInvalidationPrefix({
      table: "leaderboard",
      identity: { levelId, scope: "level" },
    });
    console.log(`[cache] pruned ${prefix}`);
    loggingService.log({
      event: "cache:pruned",
      level: "info",
      description: prefix,
    });
    leaderboardCache.deleteByPrefix(prefix);
  },

  invalidateAll(): void {
    const prefix = buildInvalidationPrefix({
      table: "leaderboard",
      identity: { scope: "all" },
    });
    console.log(`[cache] pruned ${prefix}`);
    loggingService.log({
      event: "cache:pruned",
      level: "info",
      description: prefix,
    });
    leaderboardCache.clear();
  },
};
