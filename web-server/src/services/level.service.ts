import { getDb } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { HttpCode, LevelSchema } from "@magic-nugger-app/shared";
import type {
  Level,
  RequestCreateLevel,
  RequestUpdateActiveLevel,
  RequestUpdateLevel,
} from "@magic-nugger-app/shared";

export const levelService = {
  async getAll(): Promise<Level[]> {
    const { rows } = await getDb().query<Level>(
      `SELECT 
        id, name, description, order_index, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, max_score, is_active,
        created_at, updated_at 
      FROM levels 
      WHERE is_active = true 
      ORDER BY order_index
      `,
    );
    rows.forEach((v) => {
      console.log(LevelSchema.safeParse(v).error?.toString());
    });
    return rows;
  },

  async getById(id: string): Promise<Level> {
    const { rows } = await getDb().query<Level>(
      `SELECT 
        id, name, description, order_index, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, max_score, is_active,
        created_at, updated_at 
      FROM levels 
      WHERE 
        id = $1 
        AND is_active = true
      `,
      [id],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Level not found");
    return rows[0];
  },

  async getNextActive({
    afterId,
  }: {
    afterId: number;
  }): Promise<number | null> {
    const { rows } = await getDb().query<{ id: number }>(
      `SELECT id FROM levels
       WHERE order_index > (SELECT order_index FROM levels WHERE id = $1)
         AND is_active = true
       ORDER BY order_index ASC
       LIMIT 1
      `,
      [afterId],
    );
    return rows[0]?.id ?? null;
  },

  async create(body: RequestCreateLevel): Promise<Level> {
    const { rows } = await getDb().query<Level>(
      `INSERT INTO levels 
        (name, description, order_index, elo_min, elo_gain_correct,
        elo_loss_incorrect, time_limit_seconds, enemy_wave_config, question_gen_config, max_score)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING 
        id, name, description, order_index, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, max_score, is_active,
        created_at, updated_at 
      `,
      [
        body.name,
        body.description ?? null,
        body.order_index,
        body.elo_min,
        body.elo_gain_correct,
        body.elo_loss_incorrect,
        body.time_limit_seconds ?? null,
        JSON.stringify(body.enemy_wave_config),
        JSON.stringify(body.question_gen_config),
        body.max_score,
      ],
    );
    return rows[0];
  },

  async update(id: string, body: RequestUpdateLevel): Promise<Level> {
    const { rows } = await getDb().query<Level>(
      `UPDATE levels SET
        name = COALESCE($2, name),
        description = COALESCE($3, description),
        order_index = COALESCE($4, order_index),
        elo_min = COALESCE($5, elo_min),
        elo_gain_correct = COALESCE($6, elo_gain_correct),
        elo_loss_incorrect = COALESCE($7, elo_loss_incorrect),
        time_limit_seconds = COALESCE($8, time_limit_seconds),
        enemy_wave_config = COALESCE($9, enemy_wave_config),
        question_gen_config = COALESCE($10, question_gen_config),
        max_score = COALESCE($11, max_score),
        updated_at = now()
       WHERE id = $1
       RETURNING 
        id, name, description, order_index, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, max_score, is_active,
        created_at, updated_at
      `,
      [
        id,
        body.name ?? null,
        body.description ?? null,
        body.order_index ?? null,
        body.elo_min ?? null,
        body.elo_gain_correct ?? null,
        body.elo_loss_incorrect ?? null,
        body.time_limit_seconds ?? null,
        body.enemy_wave_config ? JSON.stringify(body.enemy_wave_config) : null,
        body.question_gen_config
          ? JSON.stringify(body.question_gen_config)
          : null,
        body.max_score ?? null,
      ],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Level not found");
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
  },

  async activate(id: string, body: RequestUpdateActiveLevel): Promise<Level> {
    const { rows } = await getDb().query<Level>(
      `UPDATE levels SET
        is_active = $2,
        updated_at = now()
       WHERE id = $1
       RETURNING 
        id, name, description, order_index, elo_min,
        elo_gain_correct, elo_loss_incorrect, time_limit_seconds,
        enemy_wave_config, question_gen_config, max_score, is_active,
        created_at, updated_at
      `,
      [id, body.is_active],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Level not found");
    return rows[0];
  },
};
