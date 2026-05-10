import type { AppDispatch, RootState } from "@/store";
import { fetchMe, loginPlayer, registerPlayer, logoutPlayer } from "@/feature/auth/state/auth.thunk";
import { clearAuth } from "@/feature/auth/state/auth.slice";
import type { RequestLogin, RequestCreatePlayer } from "@magic-nugger-app/shared";

export const handleFetchMe =
  () => async (dispatch: AppDispatch, getState: () => RootState) => {
    const { auth } = getState();
    if (auth.status !== "idle") return;
    return dispatch(fetchMe());
  };

export const handleLogin =
  (values: RequestLogin) => async (dispatch: AppDispatch, getState: () => RootState) => {
    const { auth } = getState();
    if (auth.status === "loading") return null;
    return dispatch(loginPlayer(values));
  };

export const handleRegister =
  (body: RequestCreatePlayer) => async (dispatch: AppDispatch, getState: () => RootState) => {
    const { auth } = getState();
    if (auth.status === "loading") return null;
    return dispatch(registerPlayer(body));
  };

export const handleLogout =
  () => async (dispatch: AppDispatch) => {
    await dispatch(logoutPlayer());
    dispatch(clearAuth());
  };
