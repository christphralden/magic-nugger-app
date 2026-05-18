import { isFulfilled } from "@reduxjs/toolkit";
import type { AppDispatch } from "@/store";
import type { RootState } from "@/store";
import { getPlayer } from "@/feature/player/state/player.thunk";

export const handleGetPlayer =
  (playerId: string) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    const { player } = getState();
    if (player.players[playerId]) return;

    const result = await dispatch(getPlayer(playerId));

    if (isFulfilled(getPlayer)(result)) {
      console.log("Player loaded:", result.payload);
    } else {
      console.error("Failed to load player", result.payload);
    }
  };
