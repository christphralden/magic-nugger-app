import { createSlice } from "@reduxjs/toolkit";
import { fetchLevels } from "./levels.thunk";
import type { AsyncStatus, Level } from "@magic-nugger-app/shared";

type LevelsState = {
  items: Level[];
  status: AsyncStatus;
};

const levelsSlice = createSlice({
  name: "levels",
  initialState: {
    items: [],
    status: "idle",
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
      });
  },
  selectors: {
    selectLevels: (state) => state.items,
    selectLevelsStatus: (state) => state.status,
  },
});

export const { selectLevels, selectLevelsStatus } = levelsSlice.selectors;
export const levelsReducer = levelsSlice.reducer;
