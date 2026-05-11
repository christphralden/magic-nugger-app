import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type {
  ApiResponse,
  PaginatedData,
  GlobalLeaderboardRow,
  LevelLeaderboardRow,
  LeaderboardPeriod,
} from "@magic-nugger-app/shared";
import { LEADERBOARD_PAGINATION_LIMIT } from "@/constants";

export const fetchGlobal = createAsyncThunk<
  PaginatedData<GlobalLeaderboardRow>,
  { cursor?: number; limit?: number; period?: LeaderboardPeriod }
>("leaderboard/fetchGlobal", async ({ cursor, limit = LEADERBOARD_PAGINATION_LIMIT, period = "alltime" }, { rejectWithValue }) => {
  const params = new URLSearchParams({ limit: String(limit), period });
  if (cursor !== undefined) params.set("cursor", String(cursor));

  const response = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/leaderboard/global?${params}`,
    { credentials: "include" },
  );
  const data = (await response.json()) as ApiResponse<
    PaginatedData<GlobalLeaderboardRow>
  >;
  if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
  return data.data;
});

export const fetchByLevel = createAsyncThunk<
  PaginatedData<LevelLeaderboardRow>,
  { levelId: number; cursor?: number; limit?: number; period?: LeaderboardPeriod }
>(
  "leaderboard/fetchByLevel",
  async ({ levelId, cursor, limit = LEADERBOARD_PAGINATION_LIMIT, period = "alltime" }, { rejectWithValue }) => {
    const params = new URLSearchParams({ limit: String(limit), period });
    if (cursor !== undefined) params.set("cursor", String(cursor));

    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/leaderboard/levels/${levelId}?${params}`,
      { credentials: "include" },
    );
    const data = (await response.json()) as ApiResponse<
      PaginatedData<LevelLeaderboardRow>
    >;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

