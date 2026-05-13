import { createSlice } from "@reduxjs/toolkit";
import { getGlobal, getLevel } from "./leaderboard.thunk";
import type {
  AsyncStatus,
  GlobalLeaderboardRow,
  LevelLeaderboardRow,
} from "@magic-nugger-app/shared";

type GlobalTabState = {
  items: GlobalLeaderboardRow[];
  next_cursor: string | null;
  status: AsyncStatus;
};

type LevelTabState = {
  items: LevelLeaderboardRow[];
  next_cursor: string | null;
  status: AsyncStatus;
};

type LeaderboardState = {
  global: GlobalTabState;
  byLevel: Record<number, LevelTabState>;
};

const initialTabState = {
  items: [],
  next_cursor: null,
  status: "idle" as AsyncStatus,
};

const leaderboardSlice = createSlice({
  name: "leaderboard",
  initialState: {
    global: initialTabState,
    byLevel: {},
  } as LeaderboardState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(getGlobal.pending, (state) => {
        state.global.status = "loading";
      })
      .addCase(getGlobal.fulfilled, (state, action) => {
        state.global.status = "succeeded";
        state.global.items = action.payload.items;
        state.global.next_cursor = action.payload.next_cursor;
      })
      .addCase(getGlobal.rejected, (state) => {
        state.global.status = "failed";
      })

      .addCase(getLevel.pending, (state, action) => {
        const id = action.meta.arg.levelId;
        if (!state.byLevel[id]) {
          state.byLevel[id] = { ...initialTabState };
        }
        state.byLevel[id].status = "loading";
      })
      .addCase(getLevel.fulfilled, (state, action) => {
        const id = action.meta.arg.levelId;
        state.byLevel[id] = {
          status: "succeeded",
          items: action.payload.items,
          next_cursor: action.payload.next_cursor,
        };
      })
      .addCase(getLevel.rejected, (state, action) => {
        const id = action.meta.arg.levelId;
        if (!state.byLevel[id]) {
          state.byLevel[id] = { ...initialTabState };
        }
        state.byLevel[id].status = "failed";
      });
  },
  selectors: {
    selectGlobalLeaderboard: (state) => state.global,
    selectLevelLeaderboard: (state, levelId: number) =>
      state.byLevel[levelId] ?? initialTabState,
    selectSelectedLevelLeaderboard: (state, levelId: number | null) =>
      levelId !== null ? (state.byLevel[levelId] ?? initialTabState) : initialTabState,
  },
});

export const {
  selectGlobalLeaderboard,
  selectLevelLeaderboard,
  selectSelectedLevelLeaderboard,
} = leaderboardSlice.selectors;

export const leaderboardReducer = leaderboardSlice.reducer;
