import { Router } from "express";
import { levelService } from "@/services/level.service";
import { authenticate } from "@/middleware/authenticate";
import { authorize } from "@/middleware/authorize";
import { validate } from "@/middleware/validate";
import {
  ErrorCode,
  RequestCreateLevelSchema,
  RequestUpdateActiveLevelSchema,
  RequestUpdateLevelSchema,
} from "@magic-nugger-app/shared";
import type { ApiResponse, Level } from "@magic-nugger-app/shared";

export const levelsRouter = Router();

levelsRouter.use(authenticate);

levelsRouter.get("/", async (_req, res) => {
  const levels = await levelService.getAll();

  if (levels.length === 0) {
    return res.status(ErrorCode.EMPTY).send();
  }

  res.json({ code: 200, error: null, data: levels } satisfies ApiResponse<
    Level[]
  >);
});

levelsRouter.get("/:id", async (req, res) => {
  const level = await levelService.getById(req.params.id);
  res.json({
    code: 200,
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
    res.status(201).json({
      code: 201,
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
      code: 200,
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
      code: 200,
      error: null,
      data: level,
    } satisfies ApiResponse<Level>);
  },
);

levelsRouter.delete("/:id", authorize("level:delete"), async (req, res) => {
  await levelService.delete(req.params.id);
  return res.status(ErrorCode.EMPTY).send();
});
