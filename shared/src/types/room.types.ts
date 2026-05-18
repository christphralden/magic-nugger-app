import { z } from "zod";

export const RoomStatusSchema = z.enum([
  "waiting",
  "in_progress",
  "completed",
  "cancelled",
]);
export type RoomStatus = z.infer<typeof RoomStatusSchema>;

export const RoomTypeSchema = z.enum(["pvp"]);
export type RoomType = z.infer<typeof RoomTypeSchema>;

export const RoomSchema = z.object({
  id: z.string().uuid(),
  host_id: z.string().uuid(),
  level_id: z.number().int(),
  type: RoomTypeSchema,
  status: RoomStatusSchema,
  invite_code: z.string().max(16),
  max_players: z.number().int(),
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
  level_id: z.number().int(),
  max_players: z.number().int().min(2).max(50).optional(),
});
export type RequestCreateRoom = z.infer<typeof RequestCreateRoomSchema>;

export const RequestJoinRoomSchema = z.object({
  invite_code: z.string().min(1).max(16),
});
export type RequestJoinRoom = z.infer<typeof RequestJoinRoomSchema>;

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
