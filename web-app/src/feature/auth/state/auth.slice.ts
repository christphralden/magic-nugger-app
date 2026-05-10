import { createSlice } from "@reduxjs/toolkit";
import { fetchMe, loginPlayer, registerPlayer, logoutPlayer } from "./auth.thunk";
import { patchPlayer } from "@/feature/player/state/player.thunk";
import type { AsyncStatus, ResponsePlayer } from "@magic-nugger-app/shared";

type AuthState = {
  currentPlayer: ResponsePlayer | null;
  status: AsyncStatus;
  error: string | null;
};

const authSlice = createSlice({
  name: "auth",
  initialState: {
    currentPlayer: null,
    status: "idle",
    error: null,
  } as AuthState,
  reducers: {
    clearAuth: (state) => {
      state.currentPlayer = null;
      state.status = "idle";
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchMe.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(fetchMe.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.currentPlayer = action.payload;
      })
      .addCase(fetchMe.rejected, (state) => {
        state.status = "succeeded";
        state.currentPlayer = null;
      })
      .addCase(loginPlayer.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(loginPlayer.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.currentPlayer = action.payload;
      })
      .addCase(loginPlayer.rejected, (state, action) => {
        state.status = "failed";
        state.error = (action.payload as string) ?? "Login failed";
      })
      .addCase(registerPlayer.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(registerPlayer.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.currentPlayer = action.payload;
      })
      .addCase(registerPlayer.rejected, (state, action) => {
        state.status = "failed";
        state.error = (action.payload as string) ?? "Registration failed";
      })
      .addCase(logoutPlayer.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(logoutPlayer.fulfilled, (state) => {
        state.status = "succeeded";
        state.currentPlayer = null;
      })
      .addCase(logoutPlayer.rejected, (state) => {
        state.status = "succeeded";
        state.currentPlayer = null;
      })
      .addCase(patchPlayer.fulfilled, (state, action) => {
        if (state.currentPlayer?.id === action.payload.id) {
          state.currentPlayer = action.payload;
        }
      });
  },
  selectors: {
    selectCurrentPlayer: (state) => state.currentPlayer,
    selectAuthStatus: (state) => state.status,
    selectAuthError: (state) => state.error,
    selectIsAuthenticated: (state) => state.currentPlayer !== null,
  },
});

export const { clearAuth } = authSlice.actions;
export const {
  selectCurrentPlayer,
  selectAuthStatus,
  selectAuthError,
  selectIsAuthenticated,
} = authSlice.selectors;
export const authReducer = authSlice.reducer;
