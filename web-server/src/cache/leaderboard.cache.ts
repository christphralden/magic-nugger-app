import { CacheConfig } from "@/constants/cache.js";
import type { PaginatedData } from "@magic-nugger-app/shared";
import { LruCache } from "./lru-cache.js";

export const leaderboardCache = new LruCache<PaginatedData<unknown>>(
  CacheConfig.LEADERBOARD_MAX_SIZE,
  CacheConfig.LEADERBOARD_TTL_MS,
);
