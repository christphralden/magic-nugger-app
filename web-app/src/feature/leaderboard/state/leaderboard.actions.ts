import type { AppDispatch, RootState } from "@/store";
import { getGlobal, getLevel } from "./leaderboard.thunk";
import { toastError } from "@/lib/toast";
import type { LeaderboardPeriod } from "@magic-nugger-app/shared";

export const handleGetGlobalLeaderboard =
  (
    params: {
      cursor?: string;
      limit?: number;
      period?: LeaderboardPeriod;
    } = {},
  ) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().leaderboard.global.status === "loading") return;
    const result = await dispatch(getGlobal(params));
    if (getGlobal.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load leaderboard");
  };

export const handleGetLevelLeaderboard =
  (params: {
    levelId: number;
    cursor?: string;
    limit?: number;
    period?: LeaderboardPeriod;
  }) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().leaderboard.byLevel[params.levelId]?.status === "loading")
      return;
    const result = await dispatch(getLevel(params));
    if (getLevel.rejected.match(result))
      toastError(
        (result.payload as string) ?? "Failed to load level leaderboard",
      );
  };
