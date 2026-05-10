import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";

export const authenticate = (
  req: Request,
  _res: Response,
  next: NextFunction,
) => {
  if (!req.isAuthenticated || !req.isAuthenticated()) {
    throw new AppError(HttpCode.UNAUTHORIZED, "You must be logged in");
  }
  next();
};

export function getUser(req: Request): Express.User {
  if (!req.user) {
    throw new AppError(HttpCode.UNAUTHORIZED, "You must be logged in");
  }
  return req.user;
}
