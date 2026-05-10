import { Router } from "express";
import { authenticate, getUser } from "@/middleware/authenticate.js";
import { validate } from "@/middleware/validate.js";
import { HttpCode, RequestLogEventSchema } from "@magic-nugger-app/shared";
import { loggingService } from "@/services/logging.service.js";
import type { ApiResponse } from "@magic-nugger-app/shared";

export const logsRouter = Router();

logsRouter.use(authenticate);

logsRouter.post("/", validate(RequestLogEventSchema), async (req, res) => {
  const user = getUser(req);
  loggingService.log({
    event: req.body.event,
    level: req.body.level,
    userId: user.id,
    description: req.body.description ?? null,
    metadata: req.body.metadata ?? null,
  });
  res.json({
    code: HttpCode.OK,
    error: null,
    data: null,
  } satisfies ApiResponse<null>);
});
