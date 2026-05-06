import type { ZodSchema } from "zod";
import type { Request, Response, NextFunction } from "express";
import { ApiResponse, ErrorCode, jzod } from "@magic-nugger-app/shared";

export const validate =
  <T>(schema: ZodSchema<T>) =>
  (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);

    // circuit breaks request
    if (!result.success) {
      const issue = result.error.issues[0];
      return res.status(ErrorCode.BAD_REQUEST).json({
        code: ErrorCode.BAD_REQUEST,
        data: {
          schema: jzod(schema),
        },
        error: JSON.stringify(issue),
      } satisfies ApiResponse<{ schema: any }>);
    }

    req.body = result.data;
    next();
  };
