import type { RoomWithMembers, RoomMemberDetail } from "./room.types";

export const ROOM_SSE_EVENTS = {
  INIT: "init",
  MEMBER_JOINED: "member_joined",
  MEMBER_LEFT: "member_left",
  ROOM_STARTED: "room_started",
  SESSION_STARTED: "session_started",
  SESSION_UPDATE: "session_update",
  ANSWER_UPDATE: "answer_update",
  ROOM_COMPLETED: "room_completed",
  ROOM_CANCELLED: "room_cancelled",
  ROOM_CLOSED: "room_closed",
  PLAY_FORBIDDEN: "play_forbidden",
} as const;

export type RoomSSEEventKey = (typeof ROOM_SSE_EVENTS)[keyof typeof ROOM_SSE_EVENTS];

export type RoomSSEPayloads = {
  init: RoomWithMembers;
  member_joined: RoomMemberDetail;
  member_left: { player_id: string };
  room_started: { started_at: string };
  session_started: { player_id: string };
  session_update: {
    player_id: string;
    session_status: string;
    score: number | null;
    elo_delta: number | null;
    correct_count: number | null;
    incorrect_count: number | null;
    max_streak: number | null;
  };
  answer_update: {
    player_id: string;
    score: number;
    correct_count: number;
    incorrect_count: number;
    current_streak: number;
  };
  room_completed: { ended_at: string };
  room_cancelled: Record<string, never>;
  room_closed: Record<string, never>;
  play_forbidden: { reason: "room_completed" | "already_played" };
};

export type RoomSSEEvent = {
  [K in RoomSSEEventKey]: { type: K; data: RoomSSEPayloads[K] };
}[RoomSSEEventKey];
