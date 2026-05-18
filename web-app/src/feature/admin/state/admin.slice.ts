import { createSlice } from "@reduxjs/toolkit";
import {
  getStatsAdmin,
  getPlayersAdmin,
  getActiveSessionsAdmin,
  getSessionsAdmin,
  patchPlayerEloAdmin,
  patchPlayerRoleAdmin,
  getLevelsAdmin,
  getLevelAdmin,
  createLevelAdmin,
  updateLevelAdmin,
  activateLevelAdmin,
  deleteLevelAdmin,
  clearLeaderboardCacheAdmin,
  getMemoryStatsInternal,
} from "./admin.thunk";
import type { AdminStats, AdminPlayer, MemoryStats } from "./admin.thunk";
import type { AsyncStatus, GameSession, Level } from "@magic-nugger-app/shared";

type AdminState = {
  stats: AdminStats | null;
  statsStatus: AsyncStatus;
  players: {
    items: AdminPlayer[];
    next_cursor: string | null;
    status: AsyncStatus;
  };
  activeSessions: { items: GameSession[]; status: AsyncStatus };
  sessions: {
    items: GameSession[];
    next_cursor: string | null;
    status: AsyncStatus;
    filters: { player_id?: string; level_id?: string; status?: string };
  };
  levels: { items: Level[]; status: AsyncStatus };
  selectedLevel: { data: Level | null; status: AsyncStatus };
  leaderboardCacheBust: { status: AsyncStatus };
  memoryStats: { data: MemoryStats | null; status: AsyncStatus };
  error: string | null;
};

const adminSlice = createSlice({
  name: "admin",
  initialState: {
    stats: null,
    statsStatus: "idle",
    players: {
      items: [],
      next_cursor: null,
      status: "idle",
    },
    activeSessions: {
      items: [],
      status: "idle",
    },
    sessions: {
      items: [],
      next_cursor: null,
      status: "idle",
      filters: {},
    },
    levels: {
      items: [],
      status: "idle",
    },
    selectedLevel: {
      data: null,
      status: "idle",
    },
    leaderboardCacheBust: {
      status: "idle",
    },
    memoryStats: {
      data: null,
      status: "idle",
    },
    error: null,
  } as AdminState,
  reducers: {
    resetAdminSessions: (state) => {
      state.sessions = {
        items: [],
        next_cursor: null,
        status: "idle",
        filters: state.sessions.filters,
      };
    },
    setSessionFilters: (
      state,
      action: {
        payload: { player_id?: string; level_id?: string; status?: string };
      },
    ) => {
      state.sessions.filters = action.payload;
    },
    resetAdminPlayers: (state) => {
      state.players = { items: [], next_cursor: null, status: "idle" };
    },
    resetAdminLevels: (state) => {
      state.levels = { items: [], status: "idle" };
    },
    resetSelectedLevel: (state) => {
      state.selectedLevel = { data: null, status: "idle" };
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(getStatsAdmin.pending, (state) => {
        state.statsStatus = "loading";
        state.error = null;
      })
      .addCase(getStatsAdmin.fulfilled, (state, action) => {
        state.statsStatus = "succeeded";
        state.stats = action.payload;
      })
      .addCase(getStatsAdmin.rejected, (state, action) => {
        state.statsStatus = "failed";
        state.error = (action.payload as string) ?? "Failed to fetch stats";
      })

      .addCase(getPlayersAdmin.pending, (state) => {
        state.players.status = "loading";
        state.error = null;
      })
      .addCase(getPlayersAdmin.fulfilled, (state, action) => {
        state.players.status = "succeeded";
        state.players.items = action.payload.items;
        state.players.next_cursor = action.payload.next_cursor;
      })
      .addCase(getPlayersAdmin.rejected, (state, action) => {
        state.players.status = "failed";
        state.error = (action.payload as string) ?? "Failed to fetch players";
      })

      .addCase(getActiveSessionsAdmin.pending, (state) => {
        state.activeSessions.status = "loading";
        state.error = null;
      })
      .addCase(getActiveSessionsAdmin.fulfilled, (state, action) => {
        state.activeSessions.status = "succeeded";
        state.activeSessions.items = action.payload;
      })
      .addCase(getActiveSessionsAdmin.rejected, (state, action) => {
        state.activeSessions.status = "failed";
        state.error =
          (action.payload as string) ?? "Failed to fetch active sessions";
      })

      .addCase(getSessionsAdmin.pending, (state) => {
        state.sessions.status = "loading";
        state.error = null;
      })
      .addCase(getSessionsAdmin.fulfilled, (state, action) => {
        state.sessions.status = "succeeded";
        state.sessions.items = action.payload.items;
        state.sessions.next_cursor = action.payload.next_cursor;
      })
      .addCase(getSessionsAdmin.rejected, (state, action) => {
        state.sessions.status = "failed";
        state.error = (action.payload as string) ?? "Failed to fetch sessions";
      })

      .addCase(patchPlayerEloAdmin.fulfilled, (state, action) => {
        const { id, elo } = action.meta.arg;
        const player = state.players.items.find((p) => p.id === id);
        if (player) player.current_elo = elo;
      })

      .addCase(patchPlayerRoleAdmin.fulfilled, (state, action) => {
        const { id, role } = action.meta.arg;
        const player = state.players.items.find((p) => p.id === id);
        if (player) player.role_name = role;
      })

      .addCase(getLevelsAdmin.pending, (state) => {
        state.levels.status = "loading";
        state.error = null;
      })
      .addCase(getLevelsAdmin.fulfilled, (state, action) => {
        state.levels.status = "succeeded";
        state.levels.items = action.payload;
      })
      .addCase(getLevelsAdmin.rejected, (state, action) => {
        state.levels.status = "failed";
        state.error = (action.payload as string) ?? "Failed to fetch levels";
      })

      .addCase(getLevelAdmin.pending, (state) => {
        state.selectedLevel.status = "loading";
      })
      .addCase(getLevelAdmin.fulfilled, (state, action) => {
        state.selectedLevel.status = "succeeded";
        state.selectedLevel.data = action.payload;
      })
      .addCase(getLevelAdmin.rejected, (state, action) => {
        state.selectedLevel.status = "failed";
        state.error = (action.payload as string) ?? "Failed to fetch level";
      })

      .addCase(createLevelAdmin.fulfilled, (state, action) => {
        state.levels.items.push(action.payload);
        state.levels.items.sort((a, b) => a.order_index - b.order_index);
      })

      .addCase(updateLevelAdmin.fulfilled, (state, action) => {
        const idx = state.levels.items.findIndex(
          (l) => l.id === action.payload.id,
        );
        if (idx !== -1) state.levels.items[idx] = action.payload;
        if (state.selectedLevel.data?.id === action.payload.id)
          state.selectedLevel.data = action.payload;
      })

      .addCase(activateLevelAdmin.fulfilled, (state, action) => {
        const { id, is_active } = action.payload;
        const level = state.levels.items.find((l) => l.id === id);
        if (level) level.is_active = is_active;
        if (state.selectedLevel.data?.id === id)
          state.selectedLevel.data = action.payload;
      })

      .addCase(deleteLevelAdmin.fulfilled, (state, action) => {
        state.levels.items = state.levels.items.filter((l) => l.id !== action.meta.arg.id);
        if (state.selectedLevel.data?.id === action.meta.arg.id) {
          state.selectedLevel = { data: null, status: "idle" };
        }
      })

      .addCase(clearLeaderboardCacheAdmin.pending, (state) => {
        state.leaderboardCacheBust.status = "loading";
      })
      .addCase(clearLeaderboardCacheAdmin.fulfilled, (state) => {
        state.leaderboardCacheBust.status = "succeeded";
      })
      .addCase(clearLeaderboardCacheAdmin.rejected, (state) => {
        state.leaderboardCacheBust.status = "failed";
      })

      .addCase(getMemoryStatsInternal.pending, (state) => {
        state.memoryStats.status = "loading";
        state.error = null;
      })
      .addCase(getMemoryStatsInternal.fulfilled, (state, action) => {
        state.memoryStats.status = "succeeded";
        state.memoryStats.data = action.payload;
      })
      .addCase(getMemoryStatsInternal.rejected, (state, action) => {
        state.memoryStats.status = "failed";
        state.error =
          (action.payload as string) ?? "Failed to fetch memory stats";
      });
  },
  selectors: {
    selectAdminStats: (state) => state.stats,
    selectAdminStatsStatus: (state) => state.statsStatus,
    selectAdminPlayers: (state) => state.players,
    selectAdminActiveSessions: (state) => state.activeSessions,
    selectAdminSessions: (state) => state.sessions,
    selectAdminLevels: (state) => state.levels,
    selectAdminSelectedLevel: (state) => state.selectedLevel,
    selectAdminLeaderboardCacheBust: (state) => state.leaderboardCacheBust,
    selectAdminMemoryStats: (state) => state.memoryStats,
    selectAdminError: (state) => state.error,
  },
});

export const {
  resetAdminSessions,
  resetAdminPlayers,
  resetAdminLevels,
  resetSelectedLevel,
  setSessionFilters,
} = adminSlice.actions;
export const {
  selectAdminStats,
  selectAdminStatsStatus,
  selectAdminPlayers,
  selectAdminActiveSessions,
  selectAdminSessions,
  selectAdminLevels,
  selectAdminSelectedLevel,
  selectAdminLeaderboardCacheBust,
  selectAdminMemoryStats,
  selectAdminError,
} = adminSlice.selectors;
export const adminReducer = adminSlice.reducer;
