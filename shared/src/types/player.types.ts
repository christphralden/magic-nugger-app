import { z } from "zod";

export const PlayerSchema = z.object({
  id: z.string().uuid(),
  username: z.string().max(32),
  display_name: z.string().max(64).nullable(),
  email: z.string().email(),
  avatar_url: z.string().url().nullable(),
  role_id: z.number().int().min(1),
  oauth_provider: z.string().nullable(),
  oauth_id: z.string().nullable(),
  current_elo: z.number().int().min(0),
  total_questions_answered: z.number().int().min(0),
  total_correct: z.number().int().min(0),
  total_incorrect: z.number().int().min(0),
  longest_streak: z.number().int().min(0),
  age: z.number().int().positive().nullable(),
  grade: z.number().int().positive().nullable(),
  guardian_email: z.string().email().nullable(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
  last_active_at: z.string().datetime().nullable(),
});
export type Player = z.infer<typeof PlayerSchema>;

export const RequestCreatePlayerSchema = z.object({
  username: z.string().min(3).max(32),
  email: z.string().email(),
  password: z.string().min(6).max(128),
  display_name: z.string().max(64).optional(),
  age: z.number().int().positive().optional(),
  grade: z.number().int().positive().optional(),
  guardian_email: z.string().email().optional(),
});
export type RequestCreatePlayer = z.infer<typeof RequestCreatePlayerSchema>;

export const RequestLoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});
export type RequestLogin = z.infer<typeof RequestLoginSchema>;

export const RequestUpdatePlayerSchema = z.object({
  display_name: z.string().max(64).optional(),
  username: z.string().min(3).max(32).optional(),
  avatar_url: z.string().url().optional(),
  age: z.number().int().positive().optional(),
  grade: z.number().int().positive().optional(),
  guardian_email: z.string().email().optional(),
});
export type RequestUpdatePlayer = z.infer<typeof RequestUpdatePlayerSchema>;

export const ResponsePlayerSchema = PlayerSchema.pick({
  id: true,
  username: true,
  email: true,
  display_name: true,
  current_elo: true,
  avatar_url: true,
  age: true,
  grade: true,
  guardian_email: true,
  total_questions_answered: true,
  total_correct: true,
  total_incorrect: true,
  longest_streak: true,
}).extend({
  role_name: z.string(),
});
export type ResponsePlayer = z.infer<typeof ResponsePlayerSchema>;

export const AppUserSchema = PlayerSchema.extend({
  role_name: z.string(),
  role_permissions: z.array(z.string()),
});
export type AppUser = z.infer<typeof AppUserSchema>;
