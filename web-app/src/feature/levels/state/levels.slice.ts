import { createSlice } from "@reduxjs/toolkit";
import { fetchLevels, fetchUnlockedLevels } from "./levels.thunk";
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
      .addCase(fetchLevels.pending, (state) => {
        state.status = "loading";
      })
      .addCase(fetchLevels.fulfilled, (state, action) => {
        state.status = "succeeded";
        state.items = action.payload;
      })
      .addCase(fetchLevels.rejected, (state) => {
        state.status = "failed";
      })
      .addCase(fetchUnlockedLevels.pending, (state) => {
        state.unlockedStatus = "loading";
      })
      .addCase(fetchUnlockedLevels.fulfilled, (state, action) => {
        state.unlockedStatus = "succeeded";
        state.unlockedNames = action.payload;
      })
      .addCase(fetchUnlockedLevels.rejected, (state) => {
        state.unlockedStatus = "failed";
      });
  },
  selectors: {
    selectLevels: (state) => state.items,
    selectLevelsStatus: (state) => state.status,
    selectUnlockedLevelNames: (state) => state.unlockedNames,
    selectUnlockedLevelsStatus: (state) => state.unlockedStatus,
  },
});

export const {
  selectLevels,
  selectLevelsStatus,
  selectUnlockedLevelNames,
  selectUnlockedLevelsStatus,
} = levelsSlice.selectors;
export const levelsReducer = levelsSlice.reducer;
