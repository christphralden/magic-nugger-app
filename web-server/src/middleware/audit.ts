import type { Request, Response, NextFunction } from "express";
import { db } from "@/db/client.js";
import { getClientIp } from "@/utils/connectivity.js";
import { tryCatch } from "@magic-nugger-app/shared";

const SENSITIVE_KEYS = new Set([
  "password",
  "password_hash",
  "token",
  "secret",
  "authorization",
  "sess",
  "session",
  "cookie",
]);

function sanitizeBody(body: unknown): unknown {
  if (!body || typeof body !== "object" || Array.isArray(body)) return body;
  return Object.fromEntries(
    Object.entries(body as Record<string, unknown>).filter(
      ([k]) => !SENSITIVE_KEYS.has(k.toLowerCase()),
    ),
  );
}

export const audit = (req: Request, res: Response, next: NextFunction) => {
  const userId = req.user?.id ?? null;
  const ipAddress = getClientIp(req);
  const userAgent = req.headers["user-agent"] ?? null;
  const url = req.path.replace(/^\/api/, "");

  res.on("finish", async () => {
    const statusCode = res.statusCode;
    const metadata = statusCode >= 400 ? sanitizeBody(req.body) : null;

    const [err] = await tryCatch(
      db.query(
        `INSERT INTO audit.audit_events (user_id, url, status_code, ip_address, user_agent, metadata)
         VALUES ($1, $2, $3, $4::inet, $5, $6)`,
        [
          userId,
          url,
          statusCode,
          ipAddress,
          userAgent,
          metadata ? JSON.stringify(metadata) : null,
        ],
      ),
    );

    if (err) console.error("[audit] failed to log:", err);
  });
  next();
};
