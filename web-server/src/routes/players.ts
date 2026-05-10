import { Router } from "express";
import { playerService } from "@/services/player.service";
import { validate } from "@/middleware/validate";
import { authenticate, getUser } from "@/middleware/authenticate";
import { authorize } from "@/middleware/authorize";
import { HttpCode, RequestUpdatePlayerSchema } from "@magic-nugger-app/shared";
import type { ApiResponse, ResponsePlayer } from "@magic-nugger-app/shared";

export const playersRouter = Router();

playersRouter.use(authenticate);

playersRouter.get("/:id", async (req, res) => {
  const player = await playerService.getById(req.params.id);
  res.json({
    code: HttpCode.OK,
    error: null,
    data: player,
  } satisfies ApiResponse<ResponsePlayer>);
});

playersRouter.patch(
  "/",
  authorize("player:update"),
  validate(RequestUpdatePlayerSchema),
  async (req, res) => {
    const user = getUser(req);
    const player = await playerService.update(user.id, req.body);
    res.json({
      code: HttpCode.OK,
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
      code: HttpCode.OK,
      error: null,
      data: player,
    } satisfies ApiResponse<ResponsePlayer>);
  },
);
