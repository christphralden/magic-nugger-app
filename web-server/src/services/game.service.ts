import { tx } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";
import type {
  EloHistoryReason,
  GameSession,
  ResponseAnswer,
} from "@magic-nugger-app/shared";
import { gameSessionService } from "@/services/game-session.service.js";
import { levelService } from "@/services/level.service.js";
import { playerService } from "@/services/player.service.js";
import { eloService } from "@/services/elo.service.js";
import { roomService } from "@/services/room.service.js";
import { GameSessionConfig } from "@/constants/game-session.js";

export const gameService = {
  async start({
    userId,
    levelId,
    currentElo,
    ip,
    userAgent,
    roomId,
  }: {
    userId: string;
    levelId: number;
    currentElo: number;
    ip: string;
    userAgent: string | null;
    roomId?: string;
  }): Promise<{ session: GameSession; created: boolean }> {
    return tx(async () => {
      if (roomId) {
        const room = await roomService.getById(roomId);
        if (room.status !== "in_progress") {
          throw new AppError(HttpCode.CONFLICT, "Room is not in progress");
        }
      }

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

      const session = await gameSessionService.create({
        userId,
        levelId,
        currentElo,
        ip,
        userAgent,
        roomId,
      });

      if (roomId) {
        await roomService.linkMemberSession({
          roomId,
          playerId: userId,
          sessionId: session.id,
        });
      }

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
        throw new AppError(HttpCode.NOT_FOUND, "Session not found");
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
  }): Promise<{
    levelId: number;
    eloDelta: number;
    newlyUnlockedNames: string[];
  }> {
    return tx(async () => {
      const session = await gameSessionService.getActiveById({ sessionId });
      if (!session) {
        throw new AppError(HttpCode.NOT_FOUND, "Session not found");
      }

      const eloDelta = status === "failed" ? 0 : (session.elo_delta ?? 0);
      const finalElo =
        status === "failed" ? currentElo : Math.max(0, currentElo + eloDelta);

      const reason: EloHistoryReason =
        status === "completed" ? "session_completed" : "session_failed";

      const [newlyUnlockedNames] = await Promise.all([
        status === "completed"
          ? levelService.unlockChildLevels({
              playerId: userId,
              levelId: session.level_id,
            })
          : Promise.resolve([]),
        gameSessionService.finalize({ sessionId, status, finalElo }),
        playerService.updateAfterSession({
          userId,
          eloDelta,
          status,
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

      if (session.room_id) {
        await roomService.checkAndCompleteRoom(session.room_id);
      }

      return { levelId: session.level_id, eloDelta, newlyUnlockedNames };
    });
  },

  async abandon({ sessionId }: { sessionId: string }): Promise<void> {
    await gameSessionService.abandon({ sessionId });
  },
};
