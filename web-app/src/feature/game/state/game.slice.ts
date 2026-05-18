import { createSlice } from "@reduxjs/toolkit";
import { createGameSession } from "./game.thunk";
import type { AsyncStatus } from "@magic-nugger-app/shared";

type GameState = {
  sessionId: string | null;
  status: AsyncStatus;
  error: string | null;
};

const gameSlice = createSlice({
  name: "game",
  initialState: {
    sessionId: null,
    status: "idle",
    error: null,
  } as GameState,
  reducers: {
    clearSession: (state) => {
      state.sessionId = null;
      state.status = "idle";
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(createGameSession.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(createGameSession.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.sessionId = action.payload.id;
      })
      .addCase(createGameSession.rejected, (state, action) => {
        state.status = "failed";
        state.error = action.payload as string;
      });
  },
  selectors: {
    selectGameSessionId: (state) => state.sessionId,
    selectGameStatus: (state) => state.status,
  },
});

export const { clearSession } = gameSlice.actions;
export const { selectGameSessionId, selectGameStatus } = gameSlice.selectors;
export const gameReducer = gameSlice.reducer;
