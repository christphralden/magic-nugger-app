import { db } from "@/db/client.js";
import { formatError } from "@/utils/errors.js";
import type { LogEvent, LogLevel } from "@magic-nugger-app/shared";

export const loggingService = {
  log({
    event,
    level,
    userId,
    metadata,
  }: {
    event: LogEvent;
    level: LogLevel;
    userId?: string | null;
    metadata?: Record<string, unknown> | null;
  }): void {
    db.query(
      `INSERT INTO audit.log_events (user_id, event, level, metadata)
       VALUES ($1, $2, $3, $4)`,
      [
        userId ?? null,
        event,
        level,
        metadata ? JSON.stringify(metadata) : null,
      ],
    ).catch((error) => {
      console.error("[logging] failed to insert log event:", formatError(error));
    });
  },
};
