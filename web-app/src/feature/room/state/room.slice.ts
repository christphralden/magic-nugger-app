import { createSlice } from "@reduxjs/toolkit";
import { createRoom, joinRoom, startRoom, getRoomLeaderboard } from "./room.thunk";
import type { AsyncStatus, RoomLeaderboardRow } from "@magic-nugger-app/shared";

type RoomState = {
  leaderboard: RoomLeaderboardRow[];
  leaderboardStatus: AsyncStatus;
  createStatus: AsyncStatus;
  joinStatus: AsyncStatus;
  startStatus: AsyncStatus;
};

const roomSlice = createSlice({
  name: "room",
  initialState: {
    leaderboard: [],
    leaderboardStatus: "idle",
    createStatus: "idle",
    joinStatus: "idle",
    startStatus: "idle",
  } as RoomState,
  reducers: {
    clearRoomLeaderboard: (state) => {
      state.leaderboard = [];
      state.leaderboardStatus = "idle";
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(createRoom.pending, (state) => {
        state.createStatus = "loading";
      })
      .addCase(createRoom.fulfilled, (state) => {
        state.createStatus = "succeeded";
      })
      .addCase(createRoom.rejected, (state) => {
        state.createStatus = "failed";
      })
      .addCase(joinRoom.pending, (state) => {
        state.joinStatus = "loading";
      })
      .addCase(joinRoom.fulfilled, (state) => {
        state.joinStatus = "succeeded";
      })
      .addCase(joinRoom.rejected, (state) => {
        state.joinStatus = "failed";
      })
      .addCase(startRoom.pending, (state) => {
        state.startStatus = "loading";
      })
      .addCase(startRoom.fulfilled, (state) => {
        state.startStatus = "succeeded";
      })
      .addCase(startRoom.rejected, (state) => {
        state.startStatus = "failed";
      })
      .addCase(getRoomLeaderboard.pending, (state) => {
        state.leaderboardStatus = "loading";
      })
      .addCase(getRoomLeaderboard.fulfilled, (state, action) => {
        state.leaderboardStatus = "succeeded";
        state.leaderboard = action.payload;
      })
      .addCase(getRoomLeaderboard.rejected, (state) => {
        state.leaderboardStatus = "failed";
      });
  },
  selectors: {
    selectRoomLeaderboard: (state) => state.leaderboard,
    selectRoomLeaderboardStatus: (state) => state.leaderboardStatus,
    selectRoomCreateStatus: (state) => state.createStatus,
    selectRoomJoinStatus: (state) => state.joinStatus,
    selectRoomStartStatus: (state) => state.startStatus,
  },
});

export const { clearRoomLeaderboard } = roomSlice.actions;
export const {
  selectRoomLeaderboard,
  selectRoomLeaderboardStatus,
  selectRoomCreateStatus,
  selectRoomJoinStatus,
  selectRoomStartStatus,
} = roomSlice.selectors;
export const roomReducer = roomSlice.reducer;
