import { Router } from "express";
import { authenticate, getUser } from "@/middleware/authenticate.js";
import { authorize } from "@/middleware/authorize.js";
import { validate } from "@/middleware/validate.js";
import { roomService } from "@/services/room.service.js";
import { loggingService } from "@/services/logging.service.js";
import {
  RequestCreateRoomSchema,
  RequestCreateClassroomRoomSchema,
  RequestJoinRoomSchema,
  HttpCode,
} from "@magic-nugger-app/shared";
import type {
  ApiResponse,
  Room,
  RoomWithMembers,
} from "@magic-nugger-app/shared";

export const roomsRouter = Router();

roomsRouter.use(authenticate);

roomsRouter.post(
  "/",
  authorize("room:create"),
  validate(RequestCreateRoomSchema),
  async (req, res) => {
    const user = getUser(req);
    const room = await roomService.create(user.id, req.body);
    loggingService.log({
      event: "room:created",
      level: "info",
      userId: user.id,
      metadata: { room_id: room.id, type: "pvp" },
    });
    res.status(HttpCode.CREATED).json({
      code: HttpCode.CREATED,
      error: null,
      data: room,
    } satisfies ApiResponse<Room>);
  },
);

roomsRouter.post(
  "/classroom",
  authorize("room:create", "classroom:create"),
  validate(RequestCreateClassroomRoomSchema),
  async (req, res) => {
    const user = getUser(req);
    const room = await roomService.createClassroomRoom(user.id, req.body);
    loggingService.log({
      event: "room:created",
      level: "info",
      userId: user.id,
      metadata: { room_id: room.id, type: "classroom", classroom_id: req.body.classroom_id },
    });
    res.status(HttpCode.CREATED).json({
      code: HttpCode.CREATED,
      error: null,
      data: room,
    } satisfies ApiResponse<Room>);
  },
);

roomsRouter.post(
  "/join",
  authorize("room:join"),
  validate(RequestJoinRoomSchema),
  async (req, res) => {
    const user = getUser(req);
    const room = await roomService.join(user.id, req.body.invite_code);
    loggingService.log({
      event: "room:joined",
      level: "info",
      userId: user.id,
      metadata: { room_id: room.id },
    });
    res.json({
      code: HttpCode.OK,
      error: null,
      data: room,
    } satisfies ApiResponse<Room>);
  },
);

roomsRouter.get("/", async (req, res) => {
  const user = getUser(req);
  const rooms = await roomService.getActiveForPlayer(user.id);
  res.json({
    code: HttpCode.OK,
    error: null,
    data: rooms,
  } satisfies ApiResponse<Room[]>);
});

roomsRouter.get("/:id", async (req, res) => {
  const data = await roomService.getWithMembers(req.params.id);
  res.json({
    code: HttpCode.OK,
    error: null,
    data,
  } satisfies ApiResponse<RoomWithMembers>);
});

roomsRouter.post(
  "/:id/start",
  authorize("room:start"),
  async (req, res) => {
    const user = getUser(req);
    const room = await roomService.start(req.params.id, user.id);
    loggingService.log({
      event: "room:started",
      level: "info",
      userId: user.id,
      metadata: { room_id: room.id },
    });
    res.json({
      code: HttpCode.OK,
      error: null,
      data: room,
    } satisfies ApiResponse<Room>);
  },
);

roomsRouter.post(
  "/:id/end",
  authorize("room:end"),
  async (req, res) => {
    const user = getUser(req);
    await roomService.end(req.params.id, user.id);
    loggingService.log({
      event: "room:ended",
      level: "info",
      userId: user.id,
      metadata: { room_id: req.params.id },
    });
    res.json({
      code: HttpCode.OK,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);

roomsRouter.delete(
  "/:id",
  authorize("room:cancel"),
  async (req, res) => {
    const user = getUser(req);
    await roomService.cancel(req.params.id, user.id);
    loggingService.log({
      event: "room:cancelled",
      level: "info",
      userId: user.id,
      metadata: { room_id: req.params.id },
    });
    res.json({
      code: HttpCode.OK,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  },
);
