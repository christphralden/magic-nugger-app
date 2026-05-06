import { Router } from "express";
import { authenticate, currentUser } from "@/middleware/authenticate.js";
import { validate } from "@/middleware/validate.js";
import { RequestLogEventSchema } from "@magic-nugger-app/shared";
import { loggingService } from "@/services/logging.service.js";
import type { ApiResponse } from "@magic-nugger-app/shared";

export const logsRouter = Router();

logsRouter.use(authenticate);

logsRouter.post("/", validate(RequestLogEventSchema), async (req, res) => {
  const user = currentUser(req);
  loggingService.log({
    event: req.body.event,
    level: req.body.level,
    userId: user.id,
    metadata: req.body.metadata ?? null,
  });
  res.json({ code: 200, error: null, data: null } satisfies ApiResponse<null>);
});
