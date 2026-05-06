import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { PgErrorCode } from "@/constants/db.js";
import { HttpCode, type ApiResponse } from "@magic-nugger-app/shared";
import { isPgError } from "@/utils/errors";
import { loggingService } from "@/services/logging.service";

export const errorHandler = (
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  loggingService.log({
    event: "error:unhandled",
    level: "fatal",
    description: (error as any).message || "",
  });
  console.log("[web-server][error] caught unhandled error", error);
  const isLocalEnvironment = process.env.ENVIRONMENT === "local";

  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      code: error.statusCode,
      error: error.message,
      data: null,
    } satisfies ApiResponse<null>);
  }

  if (isPgError(error)) {
    const hint = isLocalEnvironment ? ` (dev) Hint: ${error.message}` : "";
    switch (error.code) {
      case PgErrorCode.UNIQUE_VIOLATION:
        return res.status(HttpCode.CONFLICT).json({
          code: HttpCode.CONFLICT,
          error: `Resource already exists.` + hint,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.FOREIGN_KEY_VIOLATION:
        return res.status(HttpCode.NOT_FOUND).json({
          code: HttpCode.NOT_FOUND,
          error: `Invalid reference, resource not found.` + hint,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.INVALID_TEXT_REPRESENTATION:
        return res.status(HttpCode.BAD_REQUEST).json({
          code: HttpCode.BAD_REQUEST,
          error: `Invalid parameter format.` + hint,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.NOT_NULL_VIOLATION:
      case PgErrorCode.CHECK_VIOLATION:
        return res.status(HttpCode.BAD_REQUEST).json({
          code: HttpCode.BAD_REQUEST,
          error: `Invalid input.` + hint,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.INVALID_PERMISSION:
        return res.status(HttpCode.FORBIDDEN).json({
          code: HttpCode.FORBIDDEN,
          error: "Insufficient permissions",
          data: null,
        });
    }
  }

  res.status(500).json({
    code: 500,
    error: "Internal server error",
    data: null,
  } satisfies ApiResponse<null>);
};
