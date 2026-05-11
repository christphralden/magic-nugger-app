import { configureStore } from "@reduxjs/toolkit";
import { playerReducer } from "@/feature/player/state/player.slice";
import { authReducer } from "@/feature/auth/state/auth.slice";
import { leaderboardReducer } from "@/feature/leaderboard/state/leaderboard.slice";
import { levelsReducer } from "@/feature/levels/state/levels.slice";
import { adminReducer } from "@/feature/admin/state/admin.slice";

export const store = configureStore({
  reducer: {
    auth: authReducer,
    player: playerReducer,
    leaderboard: leaderboardReducer,
    levels: levelsReducer,
    admin: adminReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
