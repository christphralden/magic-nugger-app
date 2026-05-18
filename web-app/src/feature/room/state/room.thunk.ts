import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import { toastError } from "@/lib/toast";
import type {
  ApiResponse,
  Room,
  RequestCreateRoom,
  RoomLeaderboardRow,
  Question,
} from "@magic-nugger-app/shared";

export const createRoom = createAsyncThunk<Room, RequestCreateRoom>(
  "room/create",
  async (body, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    const data = (await response.json()) as ApiResponse<Room>;
    if (!response.ok || (data.code !== 200 && data.code !== 201))
      return rejectWithValue(data.error);
    return data.data;
  },
);

export const joinRoom = createAsyncThunk<Room, { invite_code: string }>(
  "room/join",
  async ({ invite_code }, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/join`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ invite_code }),
    });
    const data = (await response.json()) as ApiResponse<Room>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const startRoom = createAsyncThunk<Room, string>(
  "room/start",
  async (roomId, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/start`,
      {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
      },
    );
    const data = (await response.json()) as ApiResponse<Room>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const leaveRoom = createAsyncThunk<void, string>(
  "room/leave",
  async (roomId, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/leave`,
      { method: "DELETE", credentials: "include" },
    );
    if (!response.ok) {
      toastError("Failed to leave room");
      return rejectWithValue(null);
    }
  },
);

export const cancelRoom = createAsyncThunk<void, string>(
  "room/cancel",
  async (roomId, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}`,
      { method: "DELETE", credentials: "include" },
    );
    if (!response.ok) return rejectWithValue(null);
  },
);

export const saveRoomQuestions = createAsyncThunk<
  Room,
  { roomId: string; questions: Question[] }
>(
  "room/saveQuestions",
  async ({ roomId, questions }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/questions`,
      {
        method: "PUT",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ questions }),
      },
    );
    const data = (await response.json()) as ApiResponse<Room>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const getRoomLeaderboard = createAsyncThunk<RoomLeaderboardRow[], string>(
  "room/leaderboard",
  async (roomId, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/leaderboard/rooms/${roomId}`,
      {
        credentials: "include",
      },
    );
    const data = (await response.json()) as ApiResponse<RoomLeaderboardRow[]>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);
