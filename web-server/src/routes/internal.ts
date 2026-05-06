import { leaderboardCache } from "@/cache/leaderboard.cache";
import { internal } from "@/middleware/internal";
import { ApiResponse, HttpCode } from "@magic-nugger-app/shared";
import { Router } from "express";

// this route is not meant to be surfaced to client

export const internalRouter = Router();
internalRouter.use(internal);

internalRouter.post("/memory", async (_req, res) => {
  const usage = process.memoryUsage();
  const mb = 1024 * 1024;
  res.json({
    code: HttpCode.OK,
    error: null,
    data: {
      rss: `${(usage.rss / mb).toFixed(2)} MB`,
      heapTotal: `${(usage.heapTotal / mb).toFixed(2)} MB`,
      heapUsed: `${(usage.heapUsed / mb).toFixed(2)} MB`,
      external: `${(usage.external / mb).toFixed(2)} MB`,
      arrayBuffers: `${(usage.arrayBuffers / mb).toFixed(2)} MB`,
    },
  } satisfies ApiResponse<any>);
});

internalRouter.post("/cache/leaderboard", async (_req, res) => {
  console.log(leaderboardCache.serialize());
  res.json({
    code: HttpCode.OK,
    error: null,
    data: {
      cache: leaderboardCache.serialize(),
    },
  } satisfies ApiResponse<any>);
});
