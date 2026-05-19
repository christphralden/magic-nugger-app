import { z } from "zod";

export const LogLevelSchema = z.enum(["info", "warning", "error", "fatal"]);
export type LogLevel = z.infer<typeof LogLevelSchema>;

export const LogEventSchema = z.enum([
  "cache:hit",
  "cache:miss",
  "cache:pruned",
  "error:schema-validation",
  "error:unhandled",
  "dev:ping",
  "auth:login",
  "auth:logout",
  "auth:oauth_login",
  "auth:unauthorized",
  "session:started",
  "session:ended",
  "session:failed",
  "session:abandoned",
  "session:resumed",
  "elo:updated",
  "elo:admin_adjusted",
  "admin:role_changed",
  "admin:elo_adjusted",
  "admin:player_viewed",
  "admin:sessions_viewed",
  "level",
  "room:created",
  "room:joined",
  "room:started",
  "room:ended",
  "room:cancelled",
  "sse",
]);
export type LogEvent = z.infer<typeof LogEventSchema>;
