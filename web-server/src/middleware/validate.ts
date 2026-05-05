import type { ZodSchema } from "zod";
import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { ErrorCode, jzod } from "@magic-nugger-app/shared";

export const validate =
  <T>(schema: ZodSchema<T>) =>
  (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const issue = result.error.issues[0];
      const jsonSchema = jzod(schema);
      throw new AppError(
        ErrorCode.BAD_REQUEST,
        JSON.stringify({ reason: issue, schema: jsonSchema }),
      );
    }
    req.body = result.data;
    next();
  };
