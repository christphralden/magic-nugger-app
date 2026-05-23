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
    levelId: number | null;
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
        const prior = await gameSessionService.getByPlayerAndRoom({
          userId,
          roomId,
        });
        if (prior) {
          throw new AppError(HttpCode.CONFLICT, "Already played this room");
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
        if (!existing.room_id) {
          await gameSessionService.reconcileAbandonedElo({
            session: existing,
            currentElo,
          });
        }
      }

      const session = await gameSessionService.create({
        userId,
        levelId,
        currentElo,
        ip,
        userAgent,
        roomId,
      });

      if (!session) {
        throw new AppError(HttpCode.FORBIDDEN, "Unable to create session");
      }

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
    userId,
    isCorrect,
    timeTakenMs,
  }: {
    sessionId: string;
    userId: string;
    isCorrect: boolean;
    timeTakenMs?: number;
  }): Promise<
    ResponseAnswer & {
      room_id: string | null;
      correct_count: number;
      incorrect_count: number;
    }
  > {
    return tx(async () => {
      const session = await gameSessionService.getActiveById({ sessionId });

      if (!session) {
        throw new AppError(HttpCode.NOT_FOUND, "Session not found");
      }

      if (session.player_id !== userId) {
        throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
      }

      let delta = 0;
      if (session.level_id != null) {
        const level = await levelService.getById(String(session.level_id));
        delta = isCorrect ? level.elo_gain_correct : -level.elo_loss_incorrect;
      }

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
        room_id: session.room_id,
        correct_count: newCorrect,
        incorrect_count: newIncorrect,
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
    levelId: number | null;
    eloDelta: number;
    newlyUnlockedNames: string[];
    roomId: string | null;
    roomCompleted: boolean;
    score: number;
    correctCount: number;
    incorrectCount: number;
    maxStreak: number;
  }> {
    return tx(async () => {
      const session = await gameSessionService.getActiveById({ sessionId });
      if (!session) {
        throw new AppError(HttpCode.NOT_FOUND, "Session not found");
      }

      const reason: EloHistoryReason =
        status === "completed" ? "session_completed" : "session_failed";

      let newlyUnlockedNames: string[] = [];
      let eloDelta = 0;
      let finalElo = currentElo;

      if (session.room_id) {
        await Promise.all([
          gameSessionService.finalize({ sessionId, status, finalElo }),
          // never update player stats on a multiplayer game to avoid farming
        ]);
      } else {
        if (status !== "failed") {
          eloDelta = session.elo_delta ?? 0;
          finalElo = Math.max(0, currentElo + eloDelta);
        }

        if (status === "completed" && session.level_id != null) {
          newlyUnlockedNames = await levelService.unlockChildLevels({
            playerId: userId,
            levelId: session.level_id,
          });
        }

        await Promise.all([
          gameSessionService.finalize({ sessionId, status, finalElo }),
          playerService.updateAfterSession({
            userId,
            eloDelta,
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
      }

      let roomCompleted = false;
      if (session.room_id) {
        roomCompleted = await roomService.reconcileRoom(session.room_id);
      }

      return {
        levelId: session.level_id,
        eloDelta,
        newlyUnlockedNames,
        roomId: session.room_id ?? null,
        roomCompleted,
        score: session.score,
        correctCount: session.correct_count,
        incorrectCount: session.incorrect_count,
        maxStreak: session.max_streak,
      };
    });
  },

  async abandon({ sessionId }: { sessionId: string }): Promise<{
    roomId: string | null;
    score: number | null;
    correctCount: number | null;
    incorrectCount: number | null;
    maxStreak: number | null;
    eloDelta: number | null;
  }> {
    return tx(async () => {
      const session = await gameSessionService.getActiveById({ sessionId });
      await gameSessionService.abandon({ sessionId });
      return {
        roomId: session?.room_id ?? null,
        score: session?.score ?? null,
        correctCount: session?.correct_count ?? null,
        incorrectCount: session?.incorrect_count ?? null,
        maxStreak: session?.max_streak ?? null,
        eloDelta: session?.elo_delta ?? null,
      };
    });
  },
};
