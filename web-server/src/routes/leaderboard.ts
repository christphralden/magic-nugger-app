import { Router } from "express";
import { authenticate } from "@/middleware/authenticate";
import { leaderboardService } from "@/services/leaderboard.service";
import {
  type ApiResponse,
  type PaginatedData,
  type GlobalLeaderboardRow,
  type LevelLeaderboardRow,
  type ClassroomLeaderboardRow,
  type RoomLeaderboardRow,
  HttpCode,
} from "@magic-nugger-app/shared";
import { parsePagination } from "@/utils/pagination";
import { parsePeriod } from "@/utils/period";
import { authorize } from "@/middleware/authorize";
import { leaderboardCache } from "@/cache/leaderboard.cache";

export const leaderboardRouter = Router();
leaderboardRouter.use(authenticate);

leaderboardRouter.get("/global", async (req, res) => {
  const data = await leaderboardService.getGlobal(parsePagination(req.query));
  res.json({ code: HttpCode.OK, error: null, data } satisfies ApiResponse<
    PaginatedData<GlobalLeaderboardRow>
  >);
});

leaderboardRouter.get("/levels/:id", async (req, res) => {
  const data = await leaderboardService.getByLevel(
    Number(req.params.id),
    parsePagination(req.query),
    parsePeriod(req.query),
  );
  res.json({ code: HttpCode.OK, error: null, data } satisfies ApiResponse<
    PaginatedData<LevelLeaderboardRow>
  >);
});

leaderboardRouter.get("/classrooms/:id", async (req, res) => {
  const data = await leaderboardService.getByClassroom(
    req.params.id,
    parsePagination(req.query),
    parsePeriod(req.query),
  );
  res.json({ code: HttpCode.OK, error: null, data } satisfies ApiResponse<
    PaginatedData<ClassroomLeaderboardRow>
  >);
});

leaderboardRouter.get("/rooms/:id", async (req, res) => {
  const data = await leaderboardService.getByRoom(req.params.id);
  res.json({
    code: HttpCode.OK,
    error: null,
    data,
  } satisfies ApiResponse<RoomLeaderboardRow[]>);
});

leaderboardRouter.delete(
  "/cache/clear",
  authorize("admin:full"),
  async (_req, res) => {
    leaderboardService.invalidateAll();
    res.status(HttpCode.OK).json({
      code: HttpCode.OK,
      error: null,
      data: leaderboardCache.serialize(),
    } satisfies ApiResponse<any>);
  },
);
