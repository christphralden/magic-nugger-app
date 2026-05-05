import { db } from "@/db/client.js";
import { AppError } from "@/errors/app-error.js";
import { ErrorCode } from "@magic-nugger-app/shared";
import type {
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export const playerService = {
  async getById(id: string): Promise<ResponsePlayer> {
    const { rows } = await db.query<ResponsePlayer>(
      `SELECT id, username, display_name, current_elo, highest_level_unlocked, avatar_url FROM players WHERE id = $1`,
      [id],
    );
    if (!rows[0]) throw new AppError(ErrorCode.NOT_FOUND, "Player not found");
    return rows[0];
  },

  async update(id: string, body: RequestUpdatePlayer): Promise<ResponsePlayer> {
    const { rows } = await db.query<ResponsePlayer>(
      `UPDATE players SET
        display_name = COALESCE($2, display_name),
        username = COALESCE($3, username),
        avatar_url = COALESCE($4, avatar_url),
        updated_at = now()
       WHERE id = $1
       RETURNING id, username, display_name, current_elo, highest_level_unlocked, avatar_url`,
      [
        id,
        body.display_name ?? null,
        body.username ?? null,
        body.avatar_url ?? null,
      ],
    );
    if (!rows[0]) throw new AppError(ErrorCode.NOT_FOUND, "Player not found");
    return rows[0];
  },
};
