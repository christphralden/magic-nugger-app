import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { PgErrorCode } from "@/constants/db.js";
import { ErrorCode, type ApiResponse } from "@magic-nugger-app/shared";
import { isPgError } from "@/utils/errors";

export const errorHandler = (
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  console.log("[web-server][error] caught unhandled error", error);

  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      code: error.statusCode,
      error: error.message,
      data: null,
    } satisfies ApiResponse<null>);
  }

  if (isPgError(error)) {
    switch (error.code) {
      case PgErrorCode.UNIQUE_VIOLATION:
        return res.status(ErrorCode.CONFLICT).json({
          code: ErrorCode.CONFLICT,
          error: `Resource already exists. Hint: ${error.message}`,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.FOREIGN_KEY_VIOLATION:
        return res.status(ErrorCode.BAD_REQUEST).json({
          code: ErrorCode.BAD_REQUEST,
          error: `Invalid reference. Hint: ${error.message}`,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.INVALID_TEXT_REPRESENTATION:
        return res.status(ErrorCode.BAD_REQUEST).json({
          code: ErrorCode.BAD_REQUEST,
          error: `Invalid parameter format. Hint: ${error.message}`,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.NOT_NULL_VIOLATION:
      case PgErrorCode.CHECK_VIOLATION:
        return res.status(ErrorCode.BAD_REQUEST).json({
          code: ErrorCode.BAD_REQUEST,
          error: `Invalid input. Hint: ${error.message}`,
          data: null,
        } satisfies ApiResponse<null>);
      case PgErrorCode.INVALID_PERMISSION:
        return res.status(ErrorCode.FORBIDDEN).json({
          code: ErrorCode.FORBIDDEN,
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
