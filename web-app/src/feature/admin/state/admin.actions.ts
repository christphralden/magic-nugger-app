import type { AppDispatch, RootState } from "@/store";
import {
  fetchStatsAdmin,
  fetchPlayersAdmin,
  fetchActiveSessionsAdmin,
  fetchSessionsAdmin,
  adjustPlayerRoleAdmin,
  adjustPlayerEloAdmin,
  fetchLevelsAdmin,
  fetchLevelAdmin,
  createLevelAdmin,
  updateLevelAdmin,
  activateLevelAdmin,
  deleteLevelAdmin,
  clearLeaderboardCacheAdmin,
  fetchMemoryStatsInternal,
} from "./admin.thunk";
import type { RequestCreateLevel, RequestUpdateLevel } from "@magic-nugger-app/shared";
import { resetAdminSessions, resetAdminPlayers, setSessionFilters } from "./admin.slice";
import { toastError, toastSuccess } from "@/lib/toast";

export const handleFetchStatsAdmin =
  () => async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().admin.statsStatus === "loading") return;
    const result = await dispatch(fetchStatsAdmin());
    if (fetchStatsAdmin.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load stats");
  };

export const handleFetchPlayersAdmin =
  (params: { cursor?: string } = {}) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().admin.players.status === "loading") return;
    const result = await dispatch(fetchPlayersAdmin(params));
    if (fetchPlayersAdmin.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load players");
  };

export const handleFetchActiveSessionsAdmin =
  () => async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().admin.activeSessions.status === "loading") return;
    const result = await dispatch(fetchActiveSessionsAdmin());
    if (fetchActiveSessionsAdmin.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load active sessions");
  };

export const handleFetchSessionsAdmin =
  (params: { cursor?: string } = {}) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().admin.sessions.status === "loading") return;
    const filters = getState().admin.sessions.filters;
    const result = await dispatch(fetchSessionsAdmin({ ...filters, ...params }));
    if (fetchSessionsAdmin.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load sessions");
  };

export const handleApplySessionFilters =
  (filters: { player_id: string; level_id: string; status: string }) =>
  async (dispatch: AppDispatch) => {
    const normalized = {
      player_id: filters.player_id || undefined,
      level_id: filters.level_id || undefined,
      status: filters.status === "all" ? undefined : filters.status || undefined,
    };
    dispatch(setSessionFilters(normalized));
    dispatch(resetAdminSessions());
    const result = await dispatch(fetchSessionsAdmin(normalized));
    if (fetchSessionsAdmin.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load sessions");
  };

export const handleAdjustPlayerEloAdmin =
  (id: string, elo: number) =>
  async (dispatch: AppDispatch): Promise<boolean> => {
    const result = await dispatch(
      adjustPlayerEloAdmin({ id, elo, reason: "admin_adjustment" }),
    );
    if (adjustPlayerEloAdmin.fulfilled.match(result)) {
      toastSuccess("ELO updated");
      return true;
    }
    toastError((result.payload as string) ?? "Failed to update ELO");
    return false;
  };

export const handleAdjustPlayerRoleAdmin =
  (id: string, role: string) =>
  async (dispatch: AppDispatch): Promise<boolean> => {
    const result = await dispatch(adjustPlayerRoleAdmin({ id, role }));
    if (adjustPlayerRoleAdmin.fulfilled.match(result)) {
      toastSuccess("Role updated");
      dispatch(resetAdminPlayers());
      await dispatch(fetchPlayersAdmin({}));
      return true;
    }
    toastError((result.payload as string) ?? "Failed to update role");
    return false;
  };

export const handleFetchLevelsAdmin =
  () => async (dispatch: AppDispatch, getState: () => RootState) => {
    if (getState().admin.levels.status === "loading") return;
    const result = await dispatch(fetchLevelsAdmin());
    if (fetchLevelsAdmin.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load levels");
  };

export const handleFetchLevelAdmin =
  (id: number) => async (dispatch: AppDispatch) => {
    const result = await dispatch(fetchLevelAdmin({ id }));
    if (fetchLevelAdmin.rejected.match(result))
      toastError((result.payload as string) ?? "Failed to load level");
  };

export const handleCreateLevelAdmin =
  (data: RequestCreateLevel) =>
  async (dispatch: AppDispatch): Promise<boolean> => {
    const result = await dispatch(createLevelAdmin(data));
    if (createLevelAdmin.fulfilled.match(result)) {
      toastSuccess("Level created");
      return true;
    }
    toastError((result.payload as string) ?? "Failed to create level");
    return false;
  };

export const handleUpdateLevelAdmin =
  (id: number, data: RequestUpdateLevel) =>
  async (dispatch: AppDispatch): Promise<boolean> => {
    const result = await dispatch(updateLevelAdmin({ id, ...data }));
    if (updateLevelAdmin.fulfilled.match(result)) {
      toastSuccess("Level updated");
      return true;
    }
    toastError((result.payload as string) ?? "Failed to update level");
    return false;
  };

export const handleActivateLevelAdmin =
  (id: number, is_active: boolean) =>
  async (dispatch: AppDispatch): Promise<boolean> => {
    const result = await dispatch(activateLevelAdmin({ id, is_active }));
    if (activateLevelAdmin.fulfilled.match(result)) {
      toastSuccess(is_active ? "Level activated" : "Level deactivated");
      return true;
    }
    toastError((result.payload as string) ?? "Failed to update level status");
    return false;
  };

export const handleDeleteLevelAdmin =
  (id: number) =>
  async (dispatch: AppDispatch): Promise<boolean> => {
    const result = await dispatch(deleteLevelAdmin({ id }));
    if (deleteLevelAdmin.fulfilled.match(result)) {
      toastSuccess("Level deleted");
      return true;
    }
    toastError((result.payload as string) ?? "Failed to delete level");
    return false;
  };

export const handleClearLeaderboardCacheAdmin =
  () => async (dispatch: AppDispatch, getState: () => RootState): Promise<boolean> => {
    if (getState().admin.leaderboardCacheBust.status === "loading") return false;
    const result = await dispatch(clearLeaderboardCacheAdmin());
    if (clearLeaderboardCacheAdmin.fulfilled.match(result)) {
      toastSuccess("Leaderboard cache cleared");
      return true;
    }
    toastError((result.payload as string) ?? "Failed to clear cache");
    return false;
  };

export const handleFetchMemoryStatsInternal =
  (secret: string) => async (dispatch: AppDispatch, getState: () => RootState): Promise<boolean> => {
    if (getState().admin.memoryStats.status === "loading") return false;
    const result = await dispatch(fetchMemoryStatsInternal(secret));
    if (fetchMemoryStatsInternal.rejected.match(result)) {
      toastError((result.payload as string) ?? "Failed to fetch memory stats");
      return false;
    }
    return true;
  };
