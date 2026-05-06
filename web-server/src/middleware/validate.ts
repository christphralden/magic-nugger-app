import type { ZodSchema } from "zod";
import type { Request, Response, NextFunction } from "express";
import { ApiResponse, ErrorCode, jzod } from "@magic-nugger-app/shared";
import { loggingService } from "@/services/logging.service";

export const validate =
  <T>(schema: ZodSchema<T>) =>
  (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);

    // circuit breaks request
    if (!result.success) {
      const issue = result.error.issues[0];
      const message = JSON.stringify(issue);
      loggingService.log({
        event: "error:schema-validation",
        level: "error",
        description: message,
      });
      return res.status(ErrorCode.BAD_REQUEST).json({
        code: ErrorCode.BAD_REQUEST,
        data: {
          schema: jzod(schema),
        },
        error: message,
      } satisfies ApiResponse<{ schema: any }>);
    }

    req.body = result.data;
    next();
  };
