import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type { RootState } from "@/store";
import type {
  ApiResponse,
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export const getPlayer = createAsyncThunk<
  ResponsePlayer,
  string,
  { state: RootState }
>("player/fetchById", async (id, { rejectWithValue }) => {
  const response = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/players/${id}`,
    {
      credentials: "include",
      headers: { "Content-Type": "application/json" },
    },
  );
  const data = (await response.json()) as ApiResponse<ResponsePlayer>;
  if (!response.ok || data.code !== 200) {
    return rejectWithValue(data.error);
  }
  return data.data;
});

export const patchPlayer = createAsyncThunk<
  ResponsePlayer,
  { body: RequestUpdatePlayer },
  { state: RootState }
>("player/update", async ({ body }, { rejectWithValue }) => {
  const response = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/players`,
    {
      method: "PATCH",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    },
  );
  const data = (await response.json()) as ApiResponse<ResponsePlayer>;
  if (!response.ok || data.code !== 200) {
    return rejectWithValue(data.error);
  }
  return data.data;
});
