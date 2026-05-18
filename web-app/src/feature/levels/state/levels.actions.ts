import type { AppDispatch, RootState } from "@/store";
import { getLevels, getUnlockedLevels } from "./levels.thunk";
import { toastError } from "@/lib/toast";

export const handleGetLevels =
  () => async (dispatch: AppDispatch, getState: () => RootState) => {
    const s = getState().levels.status;
    if (s === "loading") return;
    const result = await dispatch(getLevels());
    if (getLevels.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load levels");
  };

export const handleGetUnlockedLevels =
  () => async (dispatch: AppDispatch, getState: () => RootState) => {
    const s = getState().levels.unlockedStatus;
    if (s === "loading" || s === "succeeded") return;
    const result = await dispatch(getUnlockedLevels());
    if (getUnlockedLevels.rejected.match(result))
      toastError(
        (result.payload as string) ?? "Failed to load unlocked levels",
      );
  };
