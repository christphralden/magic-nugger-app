import { z } from "zod";
import { LogEventSchema, LogLevelSchema } from "../constants/log-events.js";

export const RequestLogEventSchema = z.object({
  event: LogEventSchema,
  level: LogLevelSchema,
  metadata: z.record(z.unknown()).optional().nullable(),
  description: z.string().optional().nullable(),
});
export type RequestLogEvent = z.infer<typeof RequestLogEventSchema>;
