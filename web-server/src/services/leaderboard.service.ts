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
  ClassroomLeaderboardRow,
} from "@magic-nugger-app/shared";
import { loggingService } from "./logging.service";

function parseCompoundCursor(cursor: string | undefined): [number | null, string | null] {
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
      loggingService.log({
        event: "cache:hit",
        level: "info",
        description: key,
      });
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
         p.id, p.username, p.display_name, p.avatar_url, p.current_elo,
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
        ? `${last.current_elo}:${last.id}`
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
      loggingService.log({
        event: "cache:hit",
        level: "info",
        description: key,
      });

      return cached as PaginatedData<LevelLeaderboardRow>;
    }
    console.log(`[cache] miss ${key}`);
    loggingService.log({
      event: "cache:miss",
      level: "info",
      description: key,
    });

    const [cursorScore, cursorPlayerId] = parseCompoundCursor(pagination.cursor);
    const { rows } = await getDb().query<LevelLeaderboardRow>(
      `SELECT
         gs.player_id, p.username, p.display_name,
         MAX(gs.score) AS best_score,
         MAX(gs.max_streak) AS max_streak
       FROM game_sessions gs
       JOIN players p ON p.id = gs.player_id
       WHERE gs.level_id = $1
         AND gs.status = 'completed'
         AND ($4::timestamptz IS NULL OR gs.ended_at >= $4)
       GROUP BY gs.player_id, p.username, p.display_name
       HAVING ($2::int IS NULL OR MAX(gs.score) < $2 OR (MAX(gs.score) = $2 AND gs.player_id > $3))
       ORDER BY best_score DESC, gs.player_id ASC
       LIMIT $5`,
      [levelId, cursorScore, cursorPlayerId, periodToStartDate(period), pagination.limit],
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

  async getByClassroom(
    classroomId: string,
    pagination: CursorPagination,
    period: LeaderboardPeriod,
  ): Promise<PaginatedData<ClassroomLeaderboardRow>> {
    const key = buildCacheKey({
      table: "leaderboard",
      identity: { classroomId, scope: "classroom", period },
      pagination,
    });
    const cached = leaderboardCache.get(key);
    if (cached) {
      console.log(`[cache] hit ${key}`);
      loggingService.log({
        event: "cache:hit",
        level: "info",
        description: key,
      });

      return cached as PaginatedData<ClassroomLeaderboardRow>;
    }
    console.log(`[cache] miss ${key}`);
    loggingService.log({
      event: "cache:miss",
      level: "info",
      description: key,
    });

    const [cursorElo, cursorPlayerId] = parseCompoundCursor(pagination.cursor);
    const { rows } = await getDb().query<ClassroomLeaderboardRow>(
      `SELECT
         cm.player_id, p.username, p.display_name, cm.classroom_elo,
         COALESCE(MAX(gs.max_streak), 0) AS max_streak
       FROM classroom_members cm
       JOIN players p ON p.id = cm.player_id
       LEFT JOIN game_sessions gs ON gs.player_id = cm.player_id
         AND gs.status = 'completed'
         AND ($4::timestamptz IS NULL OR gs.ended_at >= $4)
       WHERE cm.classroom_id = $1
         AND ($2::int IS NULL OR cm.classroom_elo < $2 OR (cm.classroom_elo = $2 AND cm.player_id > $3))
       GROUP BY cm.player_id, p.username, p.display_name, cm.classroom_elo
       ORDER BY cm.classroom_elo DESC, cm.player_id ASC
       LIMIT $5`,
      [classroomId, cursorElo, cursorPlayerId, periodToStartDate(period), pagination.limit],
    );
    const last = rows[rows.length - 1];
    const next_cursor =
      rows.length === pagination.limit
        ? `${last.classroom_elo}:${last.player_id}`
        : null;
    const result: PaginatedData<ClassroomLeaderboardRow> = {
      items: rows,
      next_cursor,
    };
    leaderboardCache.set(key, result);
    return result;
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

  invalidateByClassroom(classroomId: string): void {
    const prefix = buildInvalidationPrefix({
      table: "leaderboard",
      identity: { classroomId, scope: "classroom" },
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
