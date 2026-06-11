import { Router } from "express";
import { levelService } from "@/services/level.service";
import { authenticate, getUser, isAdmin } from "@/middleware/authenticate";
import { authorize } from "@/middleware/authorize";
import { validate } from "@/middleware/validate";
import {
  HttpCode,
  RequestCreateLevelSchema,
  RequestUpdateActiveLevelSchema,
  RequestUpdateLevelSchema,
} from "@magic-nugger-app/shared";
import type { ApiResponse, Level, ResponseUnlockedLevels } from "@magic-nugger-app/shared";

export const levelsRouter = Router();

levelsRouter.use(authenticate);

levelsRouter.get("/", async (req, res) => {
  const levels = await levelService.getAll(isAdmin(req));

  if (levels.length === 0) {
    return res.status(HttpCode.EMPTY).send();
  }

  res.json({
    code: HttpCode.OK,
    error: null,
    data: levels,
  } satisfies ApiResponse<Level[]>);
});

levelsRouter.get("/unlocked", async (req, res) => {
  const user = getUser(req);
  const names = await levelService.getUnlockedByPlayer(user.id, isAdmin(req));
  res.json({
    code: HttpCode.OK,
    error: null,
    data: names,
  } satisfies ApiResponse<ResponseUnlockedLevels>);
});

levelsRouter.get("/:id", async (req, res) => {
  const level = await levelService.getById(req.params.id, isAdmin(req));
  res.json({
    code: HttpCode.OK,
    error: null,
    data: level,
  } satisfies ApiResponse<Level>);
});

levelsRouter.post(
  "/",
  authorize("level:create"),
  validate(RequestCreateLevelSchema),
  async (req, res) => {
    const level = await levelService.create(req.body);
    res.status(HttpCode.CREATED).json({
      code: HttpCode.CREATED,
      error: null,
      data: level,
    } satisfies ApiResponse<Level>);
  },
);

levelsRouter.put(
  "/:id",
  authorize("level:update"),
  validate(RequestUpdateLevelSchema),
  async (req, res) => {
    const level = await levelService.update(req.params.id, req.body);
    res.json({
      code: HttpCode.OK,
      error: null,
      data: level,
    } satisfies ApiResponse<Level>);
  },
);

levelsRouter.put(
  "/active/:id",
  authorize("level:activate"),
  validate(RequestUpdateActiveLevelSchema),
  async (req, res) => {
    const level = await levelService.activate(req.params.id, req.body);
    res.json({
      code: HttpCode.OK,
      error: null,
      data: level,
    } satisfies ApiResponse<Level>);
  },
);

levelsRouter.delete("/:id", authorize("level:delete"), async (req, res) => {
  await levelService.delete(req.params.id);
  return res.status(HttpCode.EMPTY).send();
});
