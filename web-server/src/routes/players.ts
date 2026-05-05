import { Router } from "express";
import { playerService } from "@/services/player.service.js";
import { validate } from "@/middleware/validate.js";
import { authenticate, currentUser } from "@/middleware/authenticate.js";
import { authorize } from "@/middleware/authorize.js";
import { RequestUpdatePlayerSchema, ErrorCode } from "@magic-nugger-app/shared";
import type { ApiResponse, ResponsePlayer } from "@magic-nugger-app/shared";

export const playersRouter = Router();

playersRouter.get("/:id", async (req, res) => {
  const player = await playerService.getById(req.params.id);
  res.json({
    code: 200,
    error: null,
    data: player,
  } satisfies ApiResponse<ResponsePlayer>);
});

playersRouter.use(authenticate);

playersRouter.patch(
  "/",
  authorize("player:update"),
  validate(RequestUpdatePlayerSchema),
  async (req, res) => {
    const user = currentUser(req);
    const player = await playerService.update(user.id, req.body);
    res.json({
      code: 200,
      error: null,
      data: player,
    } satisfies ApiResponse<ResponsePlayer>);
  },
);

playersRouter.patch(
  "/:id",
  authorize("admin:full"),
  validate(RequestUpdatePlayerSchema),
  async (req, res) => {
    const player = await playerService.update(req.params.id, req.body);
    res.json({
      code: 200,
      error: null,
      data: player,
    } satisfies ApiResponse<ResponsePlayer>);
  },
);
