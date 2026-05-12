import type { AppDispatch, RootState } from "@/store";
import { fetchLevels, fetchUnlockedLevels } from "./levels.thunk";
import { toastError } from "@/lib/toast";

export const handleLoadLevels =
  () =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    const s = getState().levels.status;
    if (s === "loading" || s === "succeeded") return;
    const result = await dispatch(fetchLevels());
    if (fetchLevels.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load levels");
  };

export const handleLoadUnlockedLevels =
  () =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    const s = getState().levels.unlockedStatus;
    if (s === "loading" || s === "succeeded") return;
    const result = await dispatch(fetchUnlockedLevels());
    if (fetchUnlockedLevels.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load unlocked levels");
  };
