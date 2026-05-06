import { tx } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { ErrorCode, JSONBSchema } from "@magic-nugger-app/shared";
import type {
  EloHistoryReason,
  GameSession,
  ResponseAnswer,
} from "@magic-nugger-app/shared";
import { gameSessionService } from "@/services/game-session.service.js";
import { levelService } from "@/services/level.service.js";
import { playerService } from "@/services/player.service.js";
import { eloService } from "@/services/elo.service.js";
import { GameSessionConfig } from "@/constants/game-session.js";
import z from "zod";

export const gameService = {
  async start({
    userId,
    levelId,
    currentElo,
    ip,
    userAgent,
  }: {
    userId: string;
    levelId: number;
    currentElo: number;
    ip: string;
    userAgent: string | null;
  }): Promise<{ session: GameSession; created: boolean }> {
    return tx(async () => {
      const existing = await gameSessionService.getActiveByPlayerId({
        userId,
      });
      if (existing) {
        const ageMs = Date.now() - new Date(existing.started_at).getTime();
        if (ageMs <= GameSessionConfig.RESUME_WINDOW_MS) {
          return { session: existing, created: false };
        }
        await gameSessionService.abandon({ sessionId: existing.id });
        await gameSessionService.reconcileAbandonedElo({
          session: existing,
          currentElo,
        });
      }

      const level = await levelService.getById(String(levelId));

      const questionGenConfigRes = JSONBSchema(
        z.object({ total_questions: z.number().optional() }).passthrough(),
      ).safeParse(level.question_gen_config);

      const maxAnswers = questionGenConfigRes.data?.data.total_questions ?? 0;

      const session = await gameSessionService.create({
        userId,
        levelId,
        currentElo,
        maxAnswers,
        ip,
        userAgent,
      });
      return { session, created: true };
    });
  },

  async answer({
    sessionId,
    isCorrect,
    timeTakenMs,
  }: {
    sessionId: string;
    isCorrect: boolean;
    timeTakenMs?: number;
  }): Promise<ResponseAnswer> {
    return tx(async () => {
      const session = await gameSessionService.getActiveById({ sessionId });

      if (!session) {
        throw new AppError(ErrorCode.NOT_FOUND, "Session not found");
      }

      if (
        session.correct_count + session.incorrect_count >=
        session.max_answers
      ) {
        throw new AppError(
          ErrorCode.NOT_MODIFIED,
          "Session max answers reached",
        );
      }

      const level = await levelService.getById(String(session.level_id));

      const delta = isCorrect
        ? level.elo_gain_correct
        : -level.elo_loss_incorrect;

      const newScore = session.score + delta;
      const newCorrect = session.correct_count + (isCorrect ? 1 : 0);
      const newIncorrect = session.incorrect_count + (isCorrect ? 0 : 1);
      const newStreak = isCorrect ? session.current_streak + 1 : 0;
      const newMaxStreak = Math.max(session.max_streak, newStreak);
      const newEloDelta = (session.elo_delta ?? 0) + delta;

      await Promise.all([
        gameSessionService.updateStats({
          sessionId,
          score: newScore,
          correctCount: newCorrect,
          incorrectCount: newIncorrect,
          currentStreak: newStreak,
          maxStreak: newMaxStreak,
          eloDelta: newEloDelta,
        }),
        gameSessionService.insertAnswer({
          sessionId,
          isCorrect,
          delta,
          timeTakenMs,
        }),
      ]);

      return {
        is_correct: isCorrect,
        elo_delta: delta,
        current_streak: newStreak,
        current_score: newScore,
      };
    });
  },

  async end({
    sessionId,
    userId,
    currentElo,
    status,
  }: {
    sessionId: string;
    userId: string;
    currentElo: number;
    status: "completed" | "failed";
  }): Promise<{ levelId: number }> {
    return tx(async () => {
      const session = await gameSessionService.getActiveById({ sessionId });
      if (!session) {
        throw new AppError(ErrorCode.NOT_FOUND, "Session not found");
      }

      const nextLevelId = await levelService.getNextActive({
        afterId: session.level_id,
      });

      const eloDelta = status === "failed" ? 0 : (session.elo_delta ?? 0);
      const finalElo =
        status === "failed"
          ? currentElo
          : Math.max(0, currentElo + eloDelta);

      const reason: EloHistoryReason =
        status === "completed" ? "session_completed" : "session_failed";

      await Promise.all([
        gameSessionService.finalize({ sessionId, status, finalElo }),
        playerService.updateAfterSession({
          userId,
          eloDelta,
          status,
          nextLevelId,
          totalAnswered: session.correct_count + session.incorrect_count,
          totalCorrect: session.correct_count,
          totalIncorrect: session.incorrect_count,
          maxStreak: session.max_streak,
        }),
        eloService.append({
          userId,
          sessionId,
          eloBefore: session.elo_before,
          eloAfter: finalElo,
          delta: eloDelta,
          reason,
        }),
      ]);

      return { levelId: session.level_id };
    });
  },

  async abandon({ sessionId }: { sessionId: string }): Promise<void> {
    await gameSessionService.abandon({ sessionId });
  },
};
