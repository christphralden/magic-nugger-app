import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";

export const internal = (req: Request, _res: Response, next: NextFunction) => {
  const secret = req.body?.secret;
  if (!process.env.INTERNAL_SECRET || process.env.INTERNAL_SECRET !== secret) {
    throw new AppError(
      HttpCode.UNAUTHORIZED,
      "You dont have sufficient permissions",
    );
  }
  next();
};
