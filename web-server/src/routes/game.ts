import { Router } from "express";
import { authenticate, currentUser } from "@/middleware/authenticate.js";
import { validate } from "@/middleware/validate.js";
import { getClientIp, getUserAgent } from "@/utils/connectivity.js";
import {
  RequestCreateGameSessionSchema,
  RequestAnswerSchema,
} from "@magic-nugger-app/shared";
import { gameService } from "@/services/game.service.js";
import { leaderboardService } from "@/services/leaderboard.service.js";
import { loggingService } from "@/services/logging.service.js";
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
    const user = currentUser(req);
    const { session, created } = await gameService.start({
      userId: user.id,
      levelId: req.body.level_id,
      currentElo: user.current_elo,
      ip: getClientIp(req),
      userAgent: getUserAgent(req),
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
    res.status(201).json({
      code: 201,
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
      code: 200,
      error: null,
      data: answer,
    } satisfies ApiResponse<ResponseAnswer>);
  },
);

gameRouter.post("/:id/end", async (req, res) => {
  const user = currentUser(req);
  const { levelId } = await gameService.end({
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
  res.json({ code: 200, error: null, data: null } satisfies ApiResponse<null>);
});

gameRouter.post("/:id/fail", async (req, res) => {
  const user = currentUser(req);
  const { levelId } = await gameService.end({
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
  res.json({ code: 200, error: null, data: null } satisfies ApiResponse<null>);
});

gameRouter.post("/:id/abandon", async (req, res) => {
  await gameService.abandon({ sessionId: req.params.id });
  loggingService.log({
    event: "session:abandoned",
    level: "info",
    metadata: { session_id: req.params.id },
  });
  res.json({ code: 200, error: null, data: null } satisfies ApiResponse<null>);
});
