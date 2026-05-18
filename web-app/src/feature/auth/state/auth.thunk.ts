import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type {
  ApiResponse,
  ResponsePlayer,
  RequestLogin,
  RequestCreatePlayer,
} from "@magic-nugger-app/shared";

export const getMe = createAsyncThunk<ResponsePlayer>(
  "auth/getMe",
  async (_, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/auth/me`,
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
  },
);

export const loginPlayer = createAsyncThunk<ResponsePlayer, RequestLogin>(
  "auth/login",
  async (body, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/auth/login`,
      {
        method: "POST",
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
  },
);

export const registerPlayer = createAsyncThunk<
  ResponsePlayer,
  RequestCreatePlayer
>("auth/register", async (body, { rejectWithValue }) => {
  const response = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/auth/register`,
    {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    },
  );
  const data = (await response.json()) as ApiResponse<ResponsePlayer>;
  if (!response.ok || data.code !== 201) {
    return rejectWithValue(data.error);
  }
  return data.data;
});

export const logoutPlayer = createAsyncThunk<void>(
  "auth/logout",
  async (_, { rejectWithValue }) => {
    const response = await fetch(
      `${WEB_SERVER_URL}/${API_VERSION_BASE}/auth/logout`,
      {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
      },
    );
    const data = (await response.json()) as ApiResponse<null>;
    if (!response.ok || data.code !== 200) {
      return rejectWithValue(data.error);
    }
  },
);
