import type { Request, Response, NextFunction } from "express";
import { getClientIp, getUserAgent } from "@/utils/connectivity.js";
import { formatError } from "@/utils/errors";
import { getDb } from "@/db/transaction-context";

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
    Object.entries(body as Record<string, unknown>).map(([k, v]) => {
      if (SENSITIVE_KEYS.has(k)) {
        return [k, "<REDACTED>"];
      }
      return [k, v];
    }),
  );
}

export const audit = (req: Request, res: Response, next: NextFunction) => {
  const userId = req.user?.id ?? null;
  const ipAddress = getClientIp(req);
  const userAgent = getUserAgent(req);
  const url = req.path.replace(/^\/api/, "");

  res.on("finish", () => {
    const statusCode = res.statusCode;
    const metadata = statusCode >= 400 ? sanitizeBody(req.body) : null;
    const method = req.method;

    try {
      getDb().query(
        `INSERT INTO audit.audit_events (user_id, url, status_code, ip_address, user_agent, metadata, http_method)
         VALUES ($1, $2, $3, $4::inet, $5, $6, $7)`,
        [
          userId,
          url,
          statusCode,
          ipAddress,
          userAgent,
          metadata ? JSON.stringify(metadata) : null,
          method,
        ],
      );
    } catch (error) {
      console.error("[audit] failed to log: ", formatError(error));
    }
  });
  next();
};
