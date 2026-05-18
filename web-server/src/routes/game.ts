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
      levelId: req.body.level_id,
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
    const answer = await gameService.answer({
      sessionId: req.params.id,
      isCorrect: req.body.is_correct,
      timeTakenMs: req.body.time_taken_ms,
    });
    res.json({
      code: HttpCode.OK,
      error: null,
      data: answer,
    } satisfies ApiResponse<ResponseAnswer>);
  },
);

gameRouter.post("/:id/end", async (req, res) => {
  const user = getUser(req);
  const { levelId, eloDelta, newlyUnlockedNames, roomId, roomCompleted } =
    await gameService.end({
      sessionId: req.params.id,
      userId: user.id,
      currentElo: user.current_elo,
      status: "completed",
    });
  leaderboardService.invalidateGlobal();
  leaderboardService.invalidateByLevel(levelId);
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
  const { levelId, eloDelta, roomId, roomCompleted } = await gameService.end({
    sessionId: req.params.id,
    userId: user.id,
    currentElo: user.current_elo,
    status: "failed",
  });
  leaderboardService.invalidateGlobal();
  leaderboardService.invalidateByLevel(levelId);
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
  const { roomId } = await gameService.abandon({ sessionId: req.params.id });
  loggingService.log({
    event: "session:abandoned",
    level: "info",
    metadata: { session_id: req.params.id },
  });
  if (roomId) {
    roomEventBus.publish(roomId, ROOM_SSE_EVENTS.SESSION_UPDATE, {
      player_id: user.id,
      session_status: "abandoned",
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
