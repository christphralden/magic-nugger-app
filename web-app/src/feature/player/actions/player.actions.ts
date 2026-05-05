import { isFulfilled } from "@reduxjs/toolkit";
import type { AppDispatch } from "@/store";
import type { RootState } from "@/store";
import { fetchPlayer } from "@/feature/player/state/player.thunk";

export const handlePlayerLoad =
  (playerId: string) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    const { player } = getState();
    if (player.players[playerId]) return;

    const result = await dispatch(fetchPlayer(playerId));

    if (isFulfilled(fetchPlayer)(result)) {
      console.log("Player loaded:", result.payload);
    } else {
      console.error("Failed to load player", result.payload);
    }
  };
