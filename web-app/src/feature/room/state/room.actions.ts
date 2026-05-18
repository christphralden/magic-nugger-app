import type { AppDispatch } from "@/store";
import {
  createRoom,
  joinRoom,
  startRoom,
  cancelRoom,
  getRoomLeaderboard,
} from "./room.thunk";
import { toastError, toastInfo } from "@/lib/toast";
import { isFulfilled } from "@reduxjs/toolkit";
import type { RequestCreateRoom, Room } from "@magic-nugger-app/shared";

export const handleCreateRoom =
  (body: RequestCreateRoom) =>
  async (dispatch: AppDispatch): Promise<Room | null> => {
    const result = await dispatch(createRoom(body));
    if (isFulfilled(createRoom)(result)) return result.payload;
    toastError((result.payload as string) ?? "Failed to create room");
    return null;
  };

export const handleJoinRoom =
  (invite_code: string) =>
  async (dispatch: AppDispatch): Promise<Room | null> => {
    const result = await dispatch(joinRoom({ invite_code }));
    if (isFulfilled(joinRoom)(result)) return result.payload;
    toastError((result.payload as string) ?? "Invalid or expired invite code");
    return null;
  };

export const handleStartRoom =
  (roomId: string) =>
  async (dispatch: AppDispatch): Promise<void> => {
    const result = await dispatch(startRoom(roomId));
    if (!isFulfilled(startRoom)(result)) {
      toastError((result.payload as string) ?? "Failed to start room");
    }
  };

export const handleCancelRoom =
  (roomId: string) =>
  async (dispatch: AppDispatch): Promise<void> => {
    const result = await dispatch(cancelRoom(roomId));
    if (!isFulfilled(cancelRoom)(result)) {
      toastError("Failed to destory room");
    }
  };

export const handleGetRoomLeaderboard =
  (roomId: string) =>
  async (dispatch: AppDispatch): Promise<void> => {
    const result = await dispatch(getRoomLeaderboard(roomId));
    if (!isFulfilled(getRoomLeaderboard)(result)) {
      toastError((result.payload as string) ?? "Failed to load results");
    }
  };
