import { configureStore } from "@reduxjs/toolkit";
import { playerReducer } from "@/feature/player/state/player.slice";

export const store = configureStore({
  reducer: {
    player: playerReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
