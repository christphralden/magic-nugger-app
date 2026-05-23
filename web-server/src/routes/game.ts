import { Router } from "express";
import { authenticate, getUser } from "@/middleware/authenticate.js";
import { validate } from "@/middleware/validate.js";
import { getClientIp, getUserAgent } from "@/utils/connectivity.js";
import {
  RequestCreateGameSessionSchema,
  RequestAnswerSchema,
  HttpCode,
  ROOM_SSE_EVENTS,
} from "@magic-nugger-app/shared";
import { gameService } from "@/services/game.service.js";
import { leaderboardService } from "@/services/leaderboard.service.js";
import { loggingService } from "@/services/logging.service.js";
import { roomEventBus } from "@/services/room-event-bus.js";
import { roomService } from "@/services/room.service.js";
import type {
  ApiResponse,
  GameSession,
  ResponseAnswer,
} from "@magic-nugger-app/shared";

export const gameRouter = Router();

gameRouter.use(authenticate);

gameRouter.post(
  "/",
  validate(RequestCreateGameSessionSchema),
  async (req, res) => {
    const user = getUser(req);
    const { session, created } = await gameService.start({
      userId: user.id,
      levelId: req.body.level_id ?? null,
      currentElo: user.current_elo,
      ip: getClientIp(req),
      userAgent: getUserAgent(req),
      roomId: req.body.room_id,
    });
    if (!created) {
      loggingService.log({
        event: "session:resumed",
        level: "info",
        userId: user.id,
        metadata: { session_id: session.id },
      });
      return res.json({
        code: 200,
        error: null,
        data: session,
      } satisfies ApiResponse<GameSession>);
    }
    loggingService.log({
      event: "session:started",
      level: "info",
      userId: user.id,
      metadata: { session_id: session.id, level_id: req.body.level_id },
    });
    if (session.room_id) {
      roomEventBus.publish(session.room_id, ROOM_SSE_EVENTS.SESSION_STARTED, {
        player_id: user.id,
      });
    }
    res.status(HttpCode.CREATED).json({
      code: HttpCode.CREATED,
      error: null,
      data: session,
    } satisfies ApiResponse<GameSession>);
  },
);

gameRouter.post(
  "/:id/answer",
  validate(RequestAnswerSchema),
  async (req, res) => {
    const user = getUser(req);
    const { answer, metadata } = await gameService.answer({
      sessionId: req.params.id,
      userId: user.id,
      isCorrect: req.body.is_correct,
      timeTakenMs: req.body.time_taken_ms,
    });
    if (metadata.room_id) {
      roomEventBus.publish(metadata.room_id, ROOM_SSE_EVENTS.ANSWER_UPDATE, {
        player_id: user.id,
        correct_count: metadata.correct_count,
        incorrect_count: metadata.incorrect_count,
        current_streak: answer.current_streak,
      });
    }
    res.json({
      code: HttpCode.OK,
      error: null,
      data: {
        is_correct: answer.is_correct,
        elo_delta: answer.elo_delta,
        current_streak: answer.current_streak,
        current_score: answer.current_score,
      },
    } satisfies ApiResponse<ResponseAnswer>);
  },
);

gameRouter.post("/:id/end", async (req, res) => {
  const user = getUser(req);
  const {
    levelId,
    eloDelta,
    newlyUnlockedNames,
    roomId,
    roomCompleted,
    correctCount,
    incorrectCount,
    maxStreak,
  } = await gameService.end({
    sessionId: req.params.id,
    userId: user.id,
    currentElo: user.current_elo,
    status: "completed",
  });
  leaderboardService.invalidateGlobal();
  if (levelId != null) {
    leaderboardService.invalidateByLevel(levelId);
  }
  loggingService.log({
    event: "session:ended",
    level: "info",
    userId: user.id,
    metadata: { session_id: req.params.id },
  });
  loggingService.log({
    event: "elo:updated",
    level: "info",
    userId: user.id,
    metadata: { session_id: req.params.id, reason: "session_completed" },
  });
  if (roomId) {
    roomEventBus.publish(roomId, ROOM_SSE_EVENTS.SESSION_UPDATE, {
      player_id: user.id,
      session_status: "completed",
      correct_count: correctCount,
      incorrect_count: incorrectCount,
      max_streak: maxStreak,
    });
    if (roomCompleted) {
      roomEventBus.publish(roomId, ROOM_SSE_EVENTS.ROOM_COMPLETED, {
        ended_at: new Date().toISOString(),
      });
    }
  }
  res.json({
    code: HttpCode.OK,
    error: null,
    data: { elo_gained: eloDelta, new_levels_unlocked: newlyUnlockedNames },
  } satisfies ApiResponse<{
    elo_gained: number;
    new_levels_unlocked: string[];
  }>);
});

gameRouter.post("/:id/fail", async (req, res) => {
  const user = getUser(req);
  const {
    levelId,
    eloDelta,
    roomId,
    roomCompleted,
    correctCount,
    incorrectCount,
    maxStreak,
  } = await gameService.end({
    sessionId: req.params.id,
    userId: user.id,
    currentElo: user.current_elo,
    status: "failed",
  });
  leaderboardService.invalidateGlobal();
  if (levelId != null) {
    leaderboardService.invalidateByLevel(levelId);
  }
  loggingService.log({
    event: "session:failed",
    level: "info",
    userId: user.id,
    metadata: { session_id: req.params.id },
  });
  loggingService.log({
    event: "elo:updated",
    level: "info",
    userId: user.id,
    metadata: { session_id: req.params.id, reason: "session_failed" },
  });
  if (roomId) {
    roomEventBus.publish(roomId, ROOM_SSE_EVENTS.SESSION_UPDATE, {
      player_id: user.id,
      session_status: "failed",
      correct_count: correctCount,
      incorrect_count: incorrectCount,
      max_streak: maxStreak,
    });
    if (roomCompleted) {
      roomEventBus.publish(roomId, ROOM_SSE_EVENTS.ROOM_COMPLETED, {
        ended_at: new Date().toISOString(),
      });
    }
  }
  res.json({
    code: HttpCode.OK,
    error: null,
    data: { elo_gained: eloDelta, new_levels_unlocked: [] },
  } satisfies ApiResponse<{
    elo_gained: number;
    new_levels_unlocked: string[];
  }>);
});

gameRouter.post("/:id/abandon", async (req, res) => {
  const user = getUser(req);
  const { roomId, correctCount, incorrectCount, maxStreak } =
    await gameService.abandon({ sessionId: req.params.id });
  loggingService.log({
    event: "session:abandoned",
    level: "info",
    metadata: { session_id: req.params.id },
  });
  if (roomId) {
    roomEventBus.publish(roomId, ROOM_SSE_EVENTS.SESSION_UPDATE, {
      player_id: user.id,
      session_status: "abandoned",
      correct_count: correctCount,
      incorrect_count: incorrectCount,
      max_streak: maxStreak,
    });
    const roomCompleted = await roomService.reconcileRoom(roomId);
    if (roomCompleted) {
      roomEventBus.publish(roomId, ROOM_SSE_EVENTS.ROOM_COMPLETED, {
        ended_at: new Date().toISOString(),
      });
    }
  }
  res.json({
    code: HttpCode.OK,
    error: null,
    data: null,
  } satisfies ApiResponse<null>);
});
