import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";
import { loggingService } from "@/services/logging.service";

export const authorize =
  (...permissions: string[]) =>
  (req: Request, _res: Response, next: NextFunction) => {
    const user = req.user;
    if (!user) {
      loggingService.log({
        event: "auth:unauthorized",
        level: "error",
        description: `tried to access ${req.url} without a user`,
      });
      throw new AppError(HttpCode.UNAUTHORIZED, "You must be logged in");
    }

    const perms = user.role_permissions ?? [];
    if (perms.includes("*")) return next();

    const hasAll = permissions.every((p) => perms.includes(p));
    if (!hasAll) {
      loggingService.log({
        event: "auth:unauthorized",
        level: "error",
        description: `user ${user.email} (${user.id}) forbidden access to permission ${permissions.join("|")}`,
      });
      throw new AppError(
        HttpCode.FORBIDDEN,
        "You dont have sufficient permissions",
      );
    }

    next();
  };
