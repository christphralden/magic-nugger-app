import { z } from "zod";

export const EloHistorySchema = z.object({
  id: z.number().int(),
  player_id: z.string().uuid(),
  session_id: z.string().uuid().nullable(),
  elo_before: z.number().int(),
  elo_after: z.number().int(),
  delta: z.number().int(),
  reason: z.enum([
    "session_completed",
    "session_failed",
    "admin_adjustment",
    "decay",
  ]),
  created_at: z.string().datetime(),
});
export type EloHistory = z.infer<typeof EloHistorySchema>;

export const RequestAdjustEloSchema = z.object({
  elo: z.number().int(),
  reason: z.string().min(1),
});
export type RequestAdjustElo = z.infer<typeof RequestAdjustEloSchema>;
