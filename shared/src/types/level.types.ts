import { z } from "zod";

export const LevelSchema = z.object({
  id: z.number().int(),
  name: z.string().max(64),
  description: z.string().nullable(),
  order_index: z.number().int(),
  elo_min: z.number().int().min(0),
  elo_gain_correct: z.number().int().min(0),
  elo_loss_incorrect: z.number().int().min(0),
  time_limit_seconds: z.number().int().nullable(),
  enemy_wave_config: z.record(z.unknown()),
  question_gen_config: z.record(z.unknown()),
  max_score: z.number().int().min(0),
  is_active: z.boolean(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
});
export type Level = z.infer<typeof LevelSchema>;

export const ResponseLevelSchema = LevelSchema.pick({
  id: true,
  name: true,
  description: true,
  order_index: true,
  elo_min: true,
  is_active: true,
});
export type ResponseLevel = z.infer<typeof ResponseLevelSchema>;

export const RequestCreateLevelSchema = z.object({
  name: z.string().max(64),
  description: z.string().optional(),
  order_index: z.number().int(),
  elo_min: z.number().int().min(0).default(0),
  elo_gain_correct: z.number().int().min(0).default(15),
  elo_loss_incorrect: z.number().int().min(0).default(5),
  time_limit_seconds: z.number().int().optional(),
  enemy_wave_config: z.record(z.unknown()).default({}),
  question_gen_config: z.record(z.unknown()).default({}),
  max_score: z.number().int().min(0).default(1000),
});
export type RequestCreateLevel = z.infer<typeof RequestCreateLevelSchema>;

export const RequestUpdateLevelSchema = RequestCreateLevelSchema.partial();
export type RequestUpdateLevel = z.infer<typeof RequestUpdateLevelSchema>;
