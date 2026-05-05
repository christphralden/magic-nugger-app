import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { ErrorCode } from "@magic-nugger-app/shared";

export const authenticate = (
  req: Request,
  _res: Response,
  next: NextFunction,
) => {
  if (!req.isAuthenticated || !req.isAuthenticated()) {
    throw new AppError(ErrorCode.UNAUTHORIZED, "You must be logged in");
  }
  next();
};

export function currentUser(req: Request): Express.User {
  if (!req.user) {
    throw new AppError(ErrorCode.UNAUTHORIZED, "You must be logged in");
  }
  return req.user;
}
