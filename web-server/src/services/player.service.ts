import { getDb } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { ErrorCode } from "@magic-nugger-app/shared";
import type {
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export const playerService = {
  async getById(id: string): Promise<ResponsePlayer> {
    const { rows } = await getDb().query<ResponsePlayer>(
      `SELECT 
        id, username, display_name, current_elo, highest_level_unlocked, 
        avatar_url 
      FROM players 
      WHERE id = $1
      `,
      [id],
    );
    if (!rows[0]) throw new AppError(ErrorCode.NOT_FOUND, "Player not found");
    return rows[0];
  },

  async update(id: string, body: RequestUpdatePlayer): Promise<ResponsePlayer> {
    const { rows } = await getDb().query<ResponsePlayer>(
      `UPDATE players SET
        display_name = COALESCE($2, display_name),
        username = COALESCE($3, username),
        avatar_url = COALESCE($4, avatar_url),
        updated_at = now()
       WHERE id = $1
       RETURNING id, username, display_name, current_elo, highest_level_unlocked, avatar_url
      `,
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

  async updateAfterSession({
    userId,
    eloDelta,
    status,
    nextLevelId,
    totalAnswered,
    totalCorrect,
    totalIncorrect,
    maxStreak,
  }: {
    userId: string;
    eloDelta: number;
    status: "completed" | "failed";
    nextLevelId: number | null;
    totalAnswered: number;
    totalCorrect: number;
    totalIncorrect: number;
    maxStreak: number;
  }): Promise<void> {
    await getDb().query(
      `UPDATE players SET
        current_elo = GREATEST(0, current_elo + $2),
        highest_level_unlocked = CASE
          WHEN $3 = 'completed' AND $4::int IS NOT NULL
          THEN GREATEST(highest_level_unlocked, $4::int)
          ELSE highest_level_unlocked
          END,
        total_questions_answered = total_questions_answered + $5,
        total_correct = total_correct + $6,
        total_incorrect = total_incorrect + $7,
        longest_streak = GREATEST(longest_streak, $8),
        last_active_at = now(),
        updated_at = now()
       WHERE id = $1
      `,
      [
        userId,
        eloDelta,
        status,
        nextLevelId,
        totalAnswered,
        totalCorrect,
        totalIncorrect,
        maxStreak,
      ],
    );
  },
};
