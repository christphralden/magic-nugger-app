import { getDb } from "@/db/transaction-context";
import { formatError } from "@/utils/errors.js";
import type { LogEvent, LogLevel } from "@magic-nugger-app/shared";

export const loggingService = {
  log({
    event,
    level,
    userId,
    description,
    metadata,
  }: {
    event: LogEvent;
    level: LogLevel;
    userId?: string | null;
    description?: string | null;
    metadata?: Record<string, unknown> | null;
  }): void {
    // fire and forget
    try {
      getDb().query(
        `INSERT INTO audit.log_events (user_id, event, level, description, metadata)
       VALUES ($1, $2, $3, $4, $5)`,
        [
          userId ?? null,
          event,
          level,
          description,
          metadata ? JSON.stringify(metadata) : null,
        ],
      );
      console.log(`[logging][${event}] ${description || ""}`, metadata);
    } catch (error) {
      console.error("[logging] failed to log: ", formatError(error));
    }
  },
};
