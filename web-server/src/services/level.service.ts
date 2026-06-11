import { getDb } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { levelsCache } from "@/cache/levels.cache.js";
import { HttpCode } from "@magic-nugger-app/shared";
import type {
  Level,
  RequestCreateLevel,
  RequestUpdateActiveLevel,
  RequestUpdateLevel,
} from "@magic-nugger-app/shared";
import { loggingService } from "./logging.service.js";

export const levelService = {
  async getAll(includeInactive = false): Promise<Level[]> {
    const key = `levels:all:${includeInactive}`;
    const cached = levelsCache.get(key);
    if (cached) {
      console.log(`[cache] hit ${key}`);
      return cached as Level[];
    }
    console.log(`[cache] miss ${key}`);
    loggingService.log({
      event: "cache:miss",
      level: "info",
      description: key,
    });

    const { rows } = await getDb().query<Level>(
      `SELECT
        id, name, description, order_index, child_levels, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, is_active,
        created_at, updated_at
      FROM levels
      WHERE (is_active = true OR $1::boolean)
      ORDER BY order_index
      `,
      [includeInactive],
    );
    levelsCache.set(key, rows);
    return rows;
  },

  async getById(id: string, includeInactive = false): Promise<Level> {
    const key = `levels:id=${id}:includeInactive=${includeInactive}`;
    const cached = levelsCache.get(key);
    if (cached) {
      console.log(`[cache] hit ${key}`);
      return cached as Level;
    }
    console.log(`[cache] miss ${key}`);
    loggingService.log({
      event: "cache:miss",
      level: "info",
      description: key,
    });

    const { rows } = await getDb().query<Level>(
      `SELECT
        id, name, description, order_index, child_levels, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, is_active,
        created_at, updated_at
      FROM levels
      WHERE id = $1 AND (is_active = true OR $2::boolean)
      `,
      [id, includeInactive],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Level not found");
    levelsCache.set(key, rows[0]);
    return rows[0];
  },

  async getUnlockedByPlayer(playerId: string, admin = false): Promise<string[]> {
    const { rows } = await getDb().query<{ name: string }>(
      `SELECT l.name FROM levels_unlocked lu
       JOIN levels l ON l.id = lu.level_id
       WHERE lu.player_id = $1
         AND l.is_active = true

       UNION

       SELECT name FROM levels
       WHERE order_index BETWEEN 0 AND 1
         AND is_active = true

       UNION

       SELECT name FROM levels
       WHERE order_index < 0
         AND is_active = true
         AND $2::boolean
      `,
      [playerId, admin],
    );
    return rows.map((r) => r.name);
  },

  async unlockChildLevels({
    playerId,
    levelId,
  }: {
    playerId: string;
    levelId: number;
  }): Promise<string[]> {
    const { rows } = await getDb().query<{ name: string }>(
      `INSERT INTO levels_unlocked (player_id, level_id)
       SELECT $1, l.id
       FROM levels parent
       JOIN levels l ON l.name = ANY(parent.child_levels)
       WHERE parent.id = $2
         AND parent.child_levels IS NOT NULL
         AND l.is_active = true
       ON CONFLICT DO NOTHING
       RETURNING (SELECT name FROM levels WHERE id = level_id)
      `,
      [playerId, levelId],
    );
    return rows.map((r) => r.name);
  },

  async create(body: RequestCreateLevel): Promise<Level> {
    const { rows } = await getDb().query<Level>(
      `INSERT INTO levels
        (name, description, order_index, child_levels, elo_min, elo_gain_correct,
        elo_loss_incorrect, time_limit_seconds, enemy_wave_config, question_gen_config)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING
        id, name, description, order_index, child_levels, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, is_active,
        created_at, updated_at
      `,
      [
        body.name,
        body.description ?? null,
        body.order_index,
        body.child_levels ?? null,
        body.elo_min,
        body.elo_gain_correct,
        body.elo_loss_incorrect,
        body.time_limit_seconds ?? null,
        JSON.stringify(body.enemy_wave_config),
        JSON.stringify(body.question_gen_config),
      ],
    );
    levelsCache.clear();
    return rows[0];
  },

  async update(id: string, body: RequestUpdateLevel): Promise<Level> {
    const { rows } = await getDb().query<Level>(
      `UPDATE levels SET
        name = COALESCE($2, name),
        description = COALESCE($3, description),
        order_index = COALESCE($4, order_index),
        child_levels = COALESCE($5, child_levels),
        elo_min = COALESCE($6, elo_min),
        elo_gain_correct = COALESCE($7, elo_gain_correct),
        elo_loss_incorrect = COALESCE($8, elo_loss_incorrect),
        time_limit_seconds = COALESCE($9, time_limit_seconds),
        enemy_wave_config = COALESCE($10, enemy_wave_config),
        question_gen_config = COALESCE($11, question_gen_config),
        updated_at = now()
       WHERE id = $1
       RETURNING
        id, name, description, order_index, child_levels, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, is_active,
        created_at, updated_at
      `,
      [
        id,
        body.name ?? null,
        body.description ?? null,
        body.order_index ?? null,
        body.child_levels ?? null,
        body.elo_min ?? null,
        body.elo_gain_correct ?? null,
        body.elo_loss_incorrect ?? null,
        body.time_limit_seconds ?? null,
        body.enemy_wave_config ? JSON.stringify(body.enemy_wave_config) : null,
        body.question_gen_config
          ? JSON.stringify(body.question_gen_config)
          : null,
      ],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Level not found");
    levelsCache.clear();
    return rows[0];
  },

  async delete(id: string): Promise<void> {
    await getDb().query(
      `UPDATE levels
      SET
        is_active = false,
        updated_at = now()
      WHERE id = $1
      `,
      [id],
    );
    levelsCache.clear();
  },

  async activate(id: string, body: RequestUpdateActiveLevel): Promise<Level> {
    const { rows } = await getDb().query<Level>(
      `UPDATE levels SET
        is_active = $2,
        updated_at = now()
       WHERE id = $1
       RETURNING
        id, name, description, order_index, child_levels, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, is_active,
        created_at, updated_at
      `,
      [id, body.is_active],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Level not found");
    levelsCache.clear();
    return rows[0];
  },
};
