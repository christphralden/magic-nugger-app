import type { AppDispatch, RootState } from "@/store";
import { fetchLevels } from "./levels.thunk";
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
