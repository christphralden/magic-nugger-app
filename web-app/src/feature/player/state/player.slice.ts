import { createSlice, createSelector } from "@reduxjs/toolkit";
import { weakMapMemoize } from "@reduxjs/toolkit";
import { getPlayer, patchPlayer } from "./player.thunk";
import type { ResponsePlayer } from "@magic-nugger-app/shared";

type PlayerState = {
  players: Record<string, ResponsePlayer>;
  loading: boolean;
  error: string | null;
};

const playerSlice = createSlice({
  name: "player",
  initialState: {
    players: {},
    loading: false,
    error: null,
  } as PlayerState,
  reducers: {
    clearPlayers: (state) => {
      state.players = {};
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(getPlayer.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getPlayer.fulfilled, (state, action) => {
        state.loading = false;
        state.players[action.payload.id] = action.payload;
      })
      .addCase(getPlayer.rejected, (state, action) => {
        state.loading = false;
        state.error = (action.payload as string) ?? "Failed to fetch player";
      })
      .addCase(patchPlayer.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(patchPlayer.fulfilled, (state, action) => {
        state.loading = false;
        state.players[action.payload.id] = action.payload;
      })
      .addCase(patchPlayer.rejected, (state, action) => {
        state.loading = false;
        state.error = (action.payload as string) ?? "Failed to update player";
      });
  },
  selectors: {
    selectPlayerLoading: (state) => state.loading,
    selectPlayerError: (state) => state.error,
    selectPlayerById: createSelector(
      [
        (state: PlayerState) => state,
        (_state: PlayerState, id: string) => id,
      ],
      (playerState, id) => playerState.players[id] ?? null,
      { memoize: weakMapMemoize },
    ),
    selectPlayerCount: createSelector(
      [(state: PlayerState) => state],
      (playerState) => Object.keys(playerState.players).length,
    ),
  },
});

export const { clearPlayers } = playerSlice.actions;
export const {
  selectPlayerLoading,
  selectPlayerError,
  selectPlayerById,
  selectPlayerCount,
} = playerSlice.selectors;
export const playerReducer = playerSlice.reducer;
