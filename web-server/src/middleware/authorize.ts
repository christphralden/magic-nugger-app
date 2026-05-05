import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { ErrorCode } from "@magic-nugger-app/shared";

export const authorize =
  (...permissions: string[]) =>
  (req: Request, _res: Response, next: NextFunction) => {
    const user = req.user;
    if (!user) {
      throw new AppError(ErrorCode.UNAUTHORIZED, "You must be logged in");
    }

    const perms = user.role_permissions ?? [];
    if (perms.includes("*")) return next();

    const hasAll = permissions.every((p) => perms.includes(p));
    if (!hasAll) {
      throw new AppError(
        ErrorCode.FORBIDDEN,
        "You dont have sufficient permissions",
      );
    }

    next();
  };
