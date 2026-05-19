import { createSelector, createSlice } from "@reduxjs/toolkit";
import { getLevels, getUnlockedLevels } from "./levels.thunk";
import { endGameSession } from "@/feature/game/state/game.thunk";
import type { AsyncStatus, Level } from "@magic-nugger-app/shared";

type LevelsState = {
  items: Level[];
  status: AsyncStatus;
  unlockedNames: string[];
  unlockedStatus: AsyncStatus;
};

const levelsSlice = createSlice({
  name: "levels",
  initialState: {
    items: [],
    status: "idle",
    unlockedNames: [],
    unlockedStatus: "idle",
  } as LevelsState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(getLevels.pending, (state) => {
        state.status = "loading";
      })
      .addCase(getLevels.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.items = action.payload;
      })
      .addCase(getLevels.rejected, (state) => {
        state.status = "failed";
      })
      .addCase(getUnlockedLevels.pending, (state) => {
        state.unlockedStatus = "loading";
      })
      .addCase(getUnlockedLevels.fulfilled, (state, action) => {
        state.unlockedStatus = "succeeded";
        state.unlockedNames = action.payload;
      })
      .addCase(getUnlockedLevels.rejected, (state) => {
        state.unlockedStatus = "failed";
      })
      .addCase(endGameSession.fulfilled, (state, action) => {
        const incoming = action.payload.new_levels_unlocked;
        if (incoming.length > 0) {
          state.unlockedNames = [
            ...new Set([...state.unlockedNames, ...incoming]),
          ];
        }
      });
  },
  selectors: {
    selectLevels: (state) => state.items,
    selectActiveLevels: createSelector(
      (state: LevelsState) => state.items,
      (items) =>
        items
          .filter((l) => l.is_active)
          .sort((a, b) => a.order_index - b.order_index),
    ),
    selectLevelsStatus: (state) => state.status,
    selectUnlockedLevelNames: (state) => state.unlockedNames,
    selectUnlockedLevelsStatus: (state) => state.unlockedStatus,
  },
});

export const {
  selectLevels,
  selectActiveLevels,
  selectLevelsStatus,
  selectUnlockedLevelNames,
  selectUnlockedLevelsStatus,
} = levelsSlice.selectors;
export const levelsReducer = levelsSlice.reducer;
