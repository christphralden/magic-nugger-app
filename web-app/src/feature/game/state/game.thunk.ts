import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type { ApiResponse, GameSession, ResponseAnswer } from "@magic-nugger-app/shared";

export const createGameSession = createAsyncThunk<
  GameSession,
  { level_id?: number | null; room_id?: string }
>(
  "game/createSession",
  async ({ level_id, room_id }, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/game`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ level_id, ...(room_id ? { room_id } : {}) }),
    });
    const data = (await response.json()) as ApiResponse<GameSession>;
    if (!response.ok || (data.code !== 200 && data.code !== 201))
      return rejectWithValue(data.error);
    return data.data;
  },
);

export const submitAnswer = createAsyncThunk<
  ResponseAnswer,
  { sessionId: string; is_correct: boolean; time_taken_ms?: number }
>(
  "game/submitAnswer",
  async ({ sessionId, is_correct, time_taken_ms }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/game/${sessionId}/answer`,
      {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ is_correct, time_taken_ms }),
      },
    );
    const data = (await response.json()) as ApiResponse<ResponseAnswer>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const endGameSession = createAsyncThunk<
  { elo_gained: number; new_levels_unlocked: string[] },
  { sessionId: string }
>(
  "game/endSession",
  async ({ sessionId }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/game/${sessionId}/end`,
      {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
      },
    );
    const data =
      (await response.json()) as ApiResponse<{ elo_gained: number; new_levels_unlocked: string[] }>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const failGameSession = createAsyncThunk<
  { elo_gained: number; new_levels_unlocked: string[] },
  { sessionId: string }
>(
  "game/failSession",
  async ({ sessionId }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/game/${sessionId}/fail`,
      {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
      },
    );
    const data =
      (await response.json()) as ApiResponse<{ elo_gained: number; new_levels_unlocked: string[] }>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const abandonGameSession = createAsyncThunk<void, { sessionId: string }>(
  "game/abandonSession",
  async ({ sessionId }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/game/${sessionId}/abandon`,
      {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
      },
    );
    const data = (await response.json()) as ApiResponse<null>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
  },
);
