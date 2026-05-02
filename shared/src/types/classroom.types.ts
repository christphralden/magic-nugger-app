import { z } from "zod";

export const ClassroomSchema = z.object({
  id: z.string().uuid(),
  name: z.string().max(128),
  description: z.string().nullable(),
  teacher_id: z.string().uuid(),
  visibility: z.enum(["private", "public"]),
  starting_elo: z.number().int().min(0),
  elo_cap: z.number().int().nullable(),
  invite_code: z.string().max(16),
  is_active: z.boolean(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
});
export type Classroom = z.infer<typeof ClassroomSchema>;

export const ClassroomMemberSchema = z.object({
  classroom_id: z.string().uuid(),
  player_id: z.string().uuid(),
  classroom_elo: z.number().int(),
  joined_at: z.string().datetime(),
});
export type ClassroomMember = z.infer<typeof ClassroomMemberSchema>;

export const RequestCreateClassroomSchema = z.object({
  name: z.string().min(1).max(128),
  description: z.string().optional(),
  visibility: z.enum(["private", "public"]).default("private"),
  starting_elo: z.number().int().min(0).optional(),
  elo_cap: z.number().int().optional(),
});
export type RequestCreateClassroom = z.infer<typeof RequestCreateClassroomSchema>;

export const RequestUpdateClassroomSchema = RequestCreateClassroomSchema.partial();
export type RequestUpdateClassroom = z.infer<typeof RequestUpdateClassroomSchema>;

export const RequestJoinClassroomSchema = z.object({
  invite_code: z.string().min(1).max(16),
});
export type RequestJoinClassroom = z.infer<typeof RequestJoinClassroomSchema>;

export const ResponseClassroomSchema = ClassroomSchema;
export type ResponseClassroom = z.infer<typeof ResponseClassroomSchema>;
