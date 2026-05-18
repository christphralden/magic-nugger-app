import type { AppDispatch } from "@/store";
import {
  createRoom,
  joinRoom,
  startRoom,
  cancelRoom,
  getRoomLeaderboard,
  saveRoomQuestions,
} from "./room.thunk";
import { toastError, toastInfo } from "@/lib/toast";
import { isFulfilled } from "@reduxjs/toolkit";
import type { RequestCreateRoom, Room, Question } from "@magic-nugger-app/shared";

export const handleCreateRoom =
  (body: RequestCreateRoom) =>
  async (dispatch: AppDispatch): Promise<Room | null> => {
    const result = await dispatch(createRoom(body));
    if (isFulfilled(createRoom)(result)) {
      toastInfo("Room created!");
      return result.payload;
    }
    toastError((result.payload as string) ?? "Failed to create room");
    return null;
  };

export const handleJoinRoom =
  (invite_code: string) =>
  async (dispatch: AppDispatch): Promise<Room | null> => {
    const result = await dispatch(joinRoom({ invite_code }));
    if (isFulfilled(joinRoom)(result)) {
      toastInfo("Joined room!");
      return result.payload;
    }
    toastError((result.payload as string) ?? "Invalid or expired invite code");
    return null;
  };

export const handleStartRoom =
  (roomId: string) =>
  async (dispatch: AppDispatch): Promise<void> => {
    const result = await dispatch(startRoom(roomId));
    if (isFulfilled(startRoom)(result)) {
      toastInfo("Starting game!");
      return;
    }
    toastError((result.payload as string) ?? "Failed to start room");
  };

export const handleCancelRoom =
  (roomId: string) =>
  async (dispatch: AppDispatch): Promise<void> => {
    const result = await dispatch(cancelRoom(roomId));
    if (!isFulfilled(cancelRoom)(result)) {
      toastError("Failed to destroy room");
    }
  };

export const handleSaveRoomQuestions =
  (roomId: string, questions: Question[]) =>
  async (dispatch: AppDispatch): Promise<Room | null> => {
    const result = await dispatch(saveRoomQuestions({ roomId, questions }));
    if (isFulfilled(saveRoomQuestions)(result)) {
      return result.payload;
    }
    toastError((result.payload as string) ?? "Failed to save questions");
    return null;
  };

export const handleGetRoomLeaderboard =
  (roomId: string) =>
  async (dispatch: AppDispatch): Promise<void> => {
    const result = await dispatch(getRoomLeaderboard(roomId));
    if (!isFulfilled(getRoomLeaderboard)(result)) {
      toastError((result.payload as string) ?? "Failed to load results");
    }
  };
