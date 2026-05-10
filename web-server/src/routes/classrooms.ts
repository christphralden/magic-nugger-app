import { Router } from "express";
import { classroomService } from "@/services/classroom.service";
import { authenticate, getUser } from "@/middleware/authenticate";
import { authorize } from "@/middleware/authorize";
import { validate } from "@/middleware/validate";
import { AppError } from "@/errors/app-error";
import {
  RequestCreateClassroomSchema,
  RequestUpdateClassroomSchema,
  RequestJoinClassroomSchema,
  HttpCode,
} from "@magic-nugger-app/shared";
import type { ApiResponse, Classroom } from "@magic-nugger-app/shared";
import { getDb } from "@/db/transaction-context";

export const classroomsRouter = Router();

classroomsRouter.use(authenticate);

classroomsRouter.post(
  "/",
  authorize("classroom:create"),
  validate(RequestCreateClassroomSchema),
  async (req, res) => {
    const user = getUser(req);
    const classroom = await classroomService.create(user.id, req.body);
    res.status(HttpCode.CREATED).json({
      code: HttpCode.CREATED,
      error: null,
      data: classroom,
    } satisfies ApiResponse<Classroom>);
  },
);

classroomsRouter.get("/", async (req, res) => {
  const user = getUser(req);
  const classrooms = await classroomService.get(user.id);
  res.status(HttpCode.OK).json({
    code: HttpCode.OK,
    error: null,
    data: classrooms,
  } satisfies ApiResponse<Classroom[]>);
});

classroomsRouter.get("/:id", async (req, res) => {
  const classroom = await classroomService.getById(req.params.id);
  res.json({
    code: 200,
    error: null,
    data: classroom,
  } satisfies ApiResponse<Classroom>);
});

classroomsRouter.patch(
  "/:id",
  authorize("classroom:update"),
  validate(RequestUpdateClassroomSchema),
  async (req, res) => {
    const user = getUser(req);
    const { rows } = await getDb().query<Pick<Classroom, "teacher_id">>(
      `SELECT teacher_id FROM classrooms WHERE id = $1`,
      [req.params.id],
    );
    if (!rows[0] || rows[0].teacher_id !== user.id) {
      throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
    }
    const classroom = await classroomService.update(req.params.id, req.body);
    res.json({
      code: 200,
      error: null,
      data: classroom,
    } satisfies ApiResponse<Classroom>);
  },
);

classroomsRouter.delete(
  "/:id",
  authorize("classroom:delete"),
  async (req, res) => {
    const user = getUser(req);
    const { rows } = await getDb().query<Pick<Classroom, "teacher_id">>(
      `SELECT teacher_id FROM classrooms WHERE id = $1`,
      [req.params.id],
    );
    if (!rows[0] || rows[0].teacher_id !== user.id) {
      throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
    }
    await classroomService.delete(req.params.id);
    res.json({
      code: 200,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);

classroomsRouter.post(
  "/join",
  authorize("classroom:join"),
  validate(RequestJoinClassroomSchema),
  async (req, res) => {
    const user = getUser(req);
    await classroomService.join(user.id, req.body.invite_code);
    res.json({
      code: 200,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);

classroomsRouter.delete(
  "/:id/leave",
  authorize("classroom:leave"),
  async (req, res) => {
    const user = getUser(req);
    await classroomService.leave(user.id, req.params.id);
    res.json({
      code: 200,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);
