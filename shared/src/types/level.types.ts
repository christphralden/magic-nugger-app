import { z } from "zod";
import { JSONBSchema } from "./json.types";

export const LevelSchema = z.object({
  id: z.number().int(),
  name: z.string().max(64),
  description: z.string().nullable(),
  order_index: z.number().int(),
  child_levels: z.array(z.string()).nullable(),
  elo_min: z.number().int().min(0),
  elo_gain_correct: z.number().int().min(0),
  elo_loss_incorrect: z.number().int().min(0),
  time_limit_seconds: z.number().int().nullable(),
  enemy_wave_config: JSONBSchema(z.unknown()),
  question_gen_config: JSONBSchema(z.unknown()),
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
  child_levels: z.array(z.string()).nullable().optional(),
  elo_min: z.number().int().min(0).default(0),
  elo_gain_correct: z.number().int().min(0).default(15),
  elo_loss_incorrect: z.number().int().min(0).default(5),
  time_limit_seconds: z.number().int().optional(),
  enemy_wave_config: JSONBSchema(z.unknown()).default({
    schema: 1,
    data: null,
  }),
  question_gen_config: JSONBSchema(z.unknown()).default({
    schema: 1,
    data: null,
  }),
});
export type RequestCreateLevel = z.infer<typeof RequestCreateLevelSchema>;

export const RequestUpdateLevelSchema = RequestCreateLevelSchema.partial();
export type RequestUpdateLevel = z.infer<typeof RequestUpdateLevelSchema>;

export const RequestUpdateActiveLevelSchema = z.object({
  is_active: z.boolean(),
});
export type RequestUpdateActiveLevel = z.infer<
  typeof RequestUpdateActiveLevelSchema
>;

export const ResponseUnlockedLevelsSchema = z.array(z.string());
export type ResponseUnlockedLevels = z.infer<typeof ResponseUnlockedLevelsSchema>;
