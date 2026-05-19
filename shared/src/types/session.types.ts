import { z } from "zod";

export const GameSessionStatusSchema = z.enum([
  "in_progress",
  "completed",
  "failed",
  "abandoned",
]);
export type GameSessionStatus = z.infer<typeof GameSessionStatusSchema>;

export const GameSessionSchema = z.object({
  id: z.string().uuid(),
  player_id: z.string().uuid(),
  level_id: z.number().int(),
  room_id: z.string().uuid().nullable(),
  status: GameSessionStatusSchema,
  score: z.number().int().min(0),
  elo_before: z.number().int(),
  elo_after: z.number().int().nullable(),
  elo_delta: z.number().int().nullable(),
  correct_count: z.number().int().min(0),
  incorrect_count: z.number().int().min(0),
  max_streak: z.number().int().min(0),
  current_streak: z.number().int().min(0),
  started_at: z.string().datetime(),
  ended_at: z.string().datetime().nullable(),
  client_ip: z.string().nullable(),
  user_agent: z.string().nullable(),
});
export type GameSession = z.infer<typeof GameSessionSchema>;

export const GameSessionAnswerSchema = z.object({
  id: z.number().int(),
  session_id: z.string().uuid(),
  is_correct: z.boolean(),
  elo_delta: z.number().int(),
  time_taken_ms: z.number().int().nullable(),
  answered_at: z.string().datetime(),
});
export type GameSessionAnswer = z.infer<typeof GameSessionAnswerSchema>;

export const RequestCreateGameSessionSchema = z.object({
  level_id: z.number().int(),
  room_id: z.string().uuid().optional(),
});
export type RequestCreateGameSession = z.infer<
  typeof RequestCreateGameSessionSchema
>;

export const RequestAnswerSchema = z.object({
  is_correct: z.boolean(),
  time_taken_ms: z.number().int().optional(),
});
export type RequestAnswer = z.infer<typeof RequestAnswerSchema>;

export const ResponseGameSessionSchema = GameSessionSchema;
export type ResponseGameSession = z.infer<typeof ResponseGameSessionSchema>;

export const ResponseAnswerSchema = z.object({
  is_correct: z.boolean(),
  elo_delta: z.number().int(),
  current_streak: z.number().int(),
  current_score: z.number().int(),
});
export type ResponseAnswer = z.infer<typeof ResponseAnswerSchema>;

export const ResponseGameSessionCompleteSchema = z.object({
  final_elo: z.number().int(),
  elo_delta: z.number().int(),
  new_levels_unlocked: z.array(z.number().int()),
});

export type ResponseGameSessionComplete = z.infer<
  typeof ResponseGameSessionCompleteSchema
>;
