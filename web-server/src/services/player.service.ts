import { getDb } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";
import type {
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export const playerService = {
  async getById(id: string): Promise<ResponsePlayer> {
    const { rows } = await getDb().query<ResponsePlayer>(
      `SELECT
        id, username, display_name, current_elo,
        total_questions_answered, total_correct, total_incorrect, longest_streak,
        avatar_url, age, grade, guardian_email
      FROM players
      WHERE id = $1
      `,
      [id],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Player not found");
    return rows[0];
  },

  async update(id: string, body: RequestUpdatePlayer): Promise<ResponsePlayer> {
    const { rows } = await getDb().query<ResponsePlayer>(
      `UPDATE players SET
        display_name   = COALESCE($2, display_name),
        username       = COALESCE($3, username),
        avatar_url     = COALESCE($4, avatar_url),
        age            = COALESCE($5, age),
        grade          = COALESCE($6, grade),
        guardian_email = COALESCE($7, guardian_email),
        updated_at     = now()
       WHERE id = $1
       RETURNING
        id, username, display_name, current_elo,
        total_questions_answered, total_correct, total_incorrect, longest_streak,
        avatar_url, age, grade, guardian_email
      `,
      [
        id,
        body.display_name ?? null,
        body.username ?? null,
        body.avatar_url ?? null,
        body.age ?? null,
        body.grade ?? null,
        body.guardian_email ?? null,
      ],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Player not found");
    return rows[0];
  },

  async updateAfterSession({
    userId,
    eloDelta,
    totalAnswered,
    totalCorrect,
    totalIncorrect,
    maxStreak,
  }: {
    userId: string;
    eloDelta: number;
    status: "completed" | "failed";
    totalAnswered: number;
    totalCorrect: number;
    totalIncorrect: number;
    maxStreak: number;
  }): Promise<void> {
    await getDb().query(
      `UPDATE players SET
        current_elo = GREATEST(0, current_elo + $2),
        total_questions_answered = total_questions_answered + $3,
        total_correct = total_correct + $4,
        total_incorrect = total_incorrect + $5,
        longest_streak = GREATEST(longest_streak, $6),
        last_active_at = now(),
        updated_at = now()
       WHERE id = $1
      `,
      [userId, eloDelta, totalAnswered, totalCorrect, totalIncorrect, maxStreak],
    );
  },
};
