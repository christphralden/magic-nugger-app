import { z } from "zod";
import { JSONBSchema } from "./json.types";

export const RoomStatusSchema = z.enum([
  "creation",
  "waiting",
  "in_progress",
  "completed",
  "cancelled",
]);
export type RoomStatus = z.infer<typeof RoomStatusSchema>;

export const RoomTypeSchema = z.enum(["pvp"]);
export type RoomType = z.infer<typeof RoomTypeSchema>;

export const QuestionChoiceSchema = z.object({
  text: z.string().min(1),
  is_correct: z.boolean(),
});
export type QuestionChoice = z.infer<typeof QuestionChoiceSchema>;

export const QuestionSchema = z.object({
  question: z.string().min(1),
  choices: z.array(QuestionChoiceSchema).length(4),
});
export type Question = z.infer<typeof QuestionSchema>;

export const RoomQuestionsSchema = JSONBSchema(z.array(QuestionSchema));
export type RoomQuestions = z.infer<typeof RoomQuestionsSchema>;

export const RoomSchema = z.object({
  id: z.string().uuid(),
  host_id: z.string().uuid(),
  level_id: z.number().int().nullable(),
  type: RoomTypeSchema,
  status: RoomStatusSchema,
  invite_code: z.string().max(16),
  max_players: z.number().int(),
  questions: RoomQuestionsSchema.nullable(),
  started_at: z.string().datetime().nullable(),
  ended_at: z.string().datetime().nullable(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
});
export type Room = z.infer<typeof RoomSchema>;

export const RoomMemberSchema = z.object({
  room_id: z.string().uuid(),
  player_id: z.string().uuid(),
  game_session_id: z.string().uuid().nullable(),
  joined_at: z.string().datetime(),
  deleted_at: z.string().datetime().nullable(),
});
export type RoomMember = z.infer<typeof RoomMemberSchema>;

export const RequestCreateRoomSchema = z.object({
  max_players: z.number().int().min(2).max(50).optional(),
});
export type RequestCreateRoom = z.infer<typeof RequestCreateRoomSchema>;

export const RequestJoinRoomSchema = z.object({
  invite_code: z.string().min(1).max(16),
});
export type RequestJoinRoom = z.infer<typeof RequestJoinRoomSchema>;

export const RequestSaveQuestionsSchema = z.object({
  questions: z.array(QuestionSchema).min(1),
});
export type RequestSaveQuestions = z.infer<typeof RequestSaveQuestionsSchema>;

export type RoomMemberDetail = {
  player_id: string;
  username: string;
  display_name: string | null;
  avatar_url: string | null;
  game_session_id: string | null;
  session_status: string | null;
  joined_at: string;
};

export type RoomWithMembers = {
  room: Room;
  members: RoomMemberDetail[];
};
