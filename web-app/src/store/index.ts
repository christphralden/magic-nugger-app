import { configureStore } from "@reduxjs/toolkit";
import { playerReducer } from "@/feature/player/state/player.slice";
import { authReducer } from "@/feature/auth/state/auth.slice";

export const store = configureStore({
  reducer: {
    auth: authReducer,
    player: playerReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
