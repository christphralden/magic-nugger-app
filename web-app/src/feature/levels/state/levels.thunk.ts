import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type {
  ApiResponse,
  Level,
  ResponseUnlockedLevels,
} from "@magic-nugger-app/shared";

export const getLevels = createAsyncThunk<Level[]>(
  "levels/getLevels",
  async (_, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/levels`,
      { credentials: "include" },
    );
    if (response.status === 204) return [];
    const data = (await response.json()) as ApiResponse<Level[]>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);

export const getUnlockedLevels = createAsyncThunk<ResponseUnlockedLevels>(
  "levels/getUnlockedLevels",
  async (_, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/levels/unlocked`,
      { credentials: "include" },
    );
    const data = (await response.json()) as ApiResponse<ResponseUnlockedLevels>;
    if (!response.ok || data.code !== 200) return rejectWithValue(data.error);
    return data.data;
  },
);
