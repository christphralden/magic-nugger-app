import { CacheConfig } from "@/constants/cache.js";
import { LruCache } from "./lru-cache.js";

export const levelsCache = new LruCache<unknown>(
  CacheConfig.LEVEL_MAX_SIZE,
  CacheConfig.LEVEL_TTL_MS,
);
