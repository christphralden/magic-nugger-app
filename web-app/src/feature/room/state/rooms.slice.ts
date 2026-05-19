import { createSlice } from "@reduxjs/toolkit";
import { getRooms, leaveRoom } from "./room.thunk";
import type { Room, AsyncStatus } from "@magic-nugger-app/shared";

type RoomsState = {
  rooms: Room[];
  roomsStatus: AsyncStatus;
};

const roomsSlice = createSlice({
  name: "rooms",
  initialState: { rooms: [], roomsStatus: "idle" } as RoomsState,
  reducers: {},
  extraReducers: (builder) =>
    builder
      .addCase(getRooms.pending, (state) => {
        state.roomsStatus = "loading";
      })
      .addCase(getRooms.fulfilled, (state, action) => {
        state.rooms = action.payload;
        state.roomsStatus = "succeeded";
      })
      .addCase(getRooms.rejected, (state) => {
        state.roomsStatus = "failed";
      })
      .addCase(leaveRoom.fulfilled, (state, action) => {
        state.rooms = state.rooms.filter((r) => r.id !== action.meta.arg);
      }),
  selectors: {
    selectRooms: (state) => state.rooms,
    selectRoomsStatus: (state) => state.roomsStatus,
  },
});

export const { selectRooms, selectRoomsStatus } = roomsSlice.selectors;
export const roomsReducer = roomsSlice.reducer;
