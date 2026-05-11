import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type {
  ApiResponse,
  PaginatedData,
  GameSession,
  Level,
  RequestCreateLevel,
  RequestUpdateLevel,
  RequestUpdateActiveLevel,
} from "@magic-nugger-app/shared";
import { ADMIN_PAGINATION_LIMIT } from "@/constants";

export type MemoryStats = {
  rss: string;
  heapTotal: string;
  heapUsed: string;
  external: string;
  arrayBuffers: string;
};

export type AdminStats = {
  total_players: number;
  total_sessions: number;
  completed_sessions: number;
};

export type AdminPlayer = {
  id: string;
  username: string;
  display_name: string | null;
  email: string;
  role_name: string;
  current_elo: number;
  created_at: string;
};

export const fetchStatsAdmin = createAsyncThunk<AdminStats, void>(
  "admin/fetchStats",
  async (_, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/admin/stats`,
      { credentials: "include" },
    );
    const data = (await response.json()) as ApiResponse<AdminStats>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const fetchPlayersAdmin = createAsyncThunk<
  PaginatedData<AdminPlayer>,
  { cursor?: string; limit?: number }
>(
  "admin/fetchPlayers",
  async ({ cursor, limit = ADMIN_PAGINATION_LIMIT }, { rejectWithValue }) => {
    const params = new URLSearchParams({ limit: String(limit) });
    if (cursor !== undefined) params.set("cursor", cursor);
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/admin/players?${params}`,
      { credentials: "include" },
    );
    const data = (await response.json()) as ApiResponse<PaginatedData<AdminPlayer>>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const fetchActiveSessionsAdmin = createAsyncThunk<GameSession[], void>(
  "admin/fetchActiveSessions",
  async (_, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/admin/game-sessions/active`,
      { credentials: "include" },
    );
    const data = (await response.json()) as ApiResponse<GameSession[]>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const fetchSessionsAdmin = createAsyncThunk<
  PaginatedData<GameSession>,
  { player_id?: string; level_id?: string; status?: string; cursor?: string; limit?: number }
>(
  "admin/fetchSessions",
  async (
    { player_id, level_id, status, cursor, limit = ADMIN_PAGINATION_LIMIT },
    { rejectWithValue },
  ) => {
    const params = new URLSearchParams({ limit: String(limit) });
    if (player_id) params.set("player_id", player_id);
    if (level_id) params.set("level_id", level_id);
    if (status) params.set("status", status);
    if (cursor !== undefined) params.set("cursor", cursor);
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/admin/game-sessions?${params}`,
      { credentials: "include" },
    );
    const data = (await response.json()) as ApiResponse<PaginatedData<GameSession>>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const adjustPlayerRoleAdmin = createAsyncThunk<
  void,
  { id: string; role: string }
>(
  "admin/adjustPlayerRole",
  async ({ id, role }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/admin/players/${id}/role`,
      {
        method: "PATCH",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ role }),
      },
    );
    const data = (await response.json()) as ApiResponse<null>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
  },
);

export const fetchLevelsAdmin = createAsyncThunk<Level[], void>(
  "admin/fetchLevels",
  async (_, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/levels`, {
      credentials: "include",
    });
    if (response.status === 204) return [];
    const data = (await response.json()) as ApiResponse<Level[]>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const fetchLevelAdmin = createAsyncThunk<Level, { id: number }>(
  "admin/fetchLevel",
  async ({ id }, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/levels/${id}`, {
      credentials: "include",
    });
    const data = (await response.json()) as ApiResponse<Level>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const createLevelAdmin = createAsyncThunk<Level, RequestCreateLevel>(
  "admin/createLevel",
  async (payload, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/levels`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const data = (await response.json()) as ApiResponse<Level>;
    if (!response.ok || data.code !== 201) return rejectWithValue(data.error);
    return data.data;
  },
);

export const updateLevelAdmin = createAsyncThunk<
  Level,
  { id: number } & RequestUpdateLevel
>(
  "admin/updateLevel",
  async ({ id, ...payload }, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/levels/${id}`, {
      method: "PUT",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const data = (await response.json()) as ApiResponse<Level>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const activateLevelAdmin = createAsyncThunk<
  Level,
  { id: number } & RequestUpdateActiveLevel
>(
  "admin/activateLevel",
  async ({ id, ...payload }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/levels/active/${id}`,
      {
        method: "PUT",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      },
    );
    const data = (await response.json()) as ApiResponse<Level>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const deleteLevelAdmin = createAsyncThunk<void, { id: number }>(
  "admin/deleteLevel",
  async ({ id }, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/levels/${id}`, {
      method: "DELETE",
      credentials: "include",
    });
    if (response.status === 204) return;
    const data = (await response.json()) as ApiResponse<null>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
  },
);

export const clearLeaderboardCacheAdmin = createAsyncThunk<any, void>(
  "admin/clearLeaderboardCache",
  async (_, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/leaderboard/cache/clear`,
      { method: "DELETE", credentials: "include" },
    );
    const data = (await response.json()) as ApiResponse<any>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const fetchMemoryStatsInternal = createAsyncThunk<MemoryStats, string>(
  "admin/fetchMemoryStats",
  async (secret, { rejectWithValue }) => {
    const response = await fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/internal/memory`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ secret }),
    });
    const data = (await response.json()) as ApiResponse<MemoryStats>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const adjustPlayerEloAdmin = createAsyncThunk<
  void,
  { id: string; elo: number; reason: string }
>(
  "admin/adjustPlayerElo",
  async ({ id, elo, reason }, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/admin/players/${id}/elo`,
      {
        method: "PATCH",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ elo, reason }),
      },
    );
    const data = (await response.json()) as ApiResponse<null>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
  },
);
