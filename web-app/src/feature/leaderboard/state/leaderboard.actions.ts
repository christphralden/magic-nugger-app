import type { AppDispatch, RootState } from "@/store";
import { fetchGlobal, fetchByLevel } from "./leaderboard.thunk";
import { toastError } from "@/lib/toast";
import type { LeaderboardPeriod } from "@magic-nugger-app/shared";

export const handleLoadGlobal =
  (params: { cursor?: string; limit?: number; period?: LeaderboardPeriod } = {}) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().leaderboard.global.status === "loading") return;
    const result = await dispatch(fetchGlobal(params));
    if (fetchGlobal.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load leaderboard");
  };

export const handleLoadByLevel =
  (params: { levelId: number; cursor?: string; limit?: number; period?: LeaderboardPeriod }) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().leaderboard.byLevel[params.levelId]?.status === "loading") return;
    const result = await dispatch(fetchByLevel(params));
    if (fetchByLevel.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load level leaderboard");
  };
