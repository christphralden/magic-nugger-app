import { Router } from "express";
import { authenticate, getUser } from "@/middleware/authenticate.js";
import { authorize } from "@/middleware/authorize.js";
import { validate } from "@/middleware/validate.js";
import { roomService } from "@/services/room.service.js";
import { gameService } from "@/services/game.service.js";
import { roomEventBus } from "@/services/room-event-bus.js";
import { loggingService } from "@/services/logging.service.js";
import {
  RequestCreateRoomSchema,
  RequestJoinRoomSchema,
  HttpCode,
  ROOM_SSE_EVENTS,
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

    const memberDetail = await roomService.getMemberDetail(room.id, user.id);
    if (memberDetail) {
      roomEventBus.publish(
        room.id,
        ROOM_SSE_EVENTS.MEMBER_JOINED,
        memberDetail,
      );
    }

    res.json({
      code: HttpCode.OK,
      error: null,
      data: room,
    } satisfies ApiResponse<Room>);
  },
);

roomsRouter.get("/:id/events", async (req, res) => {
  const user = getUser(req);

  const isMember = await roomService.isMember(req.params.id, user.id);
  if (!isMember) {
    return res.status(HttpCode.FORBIDDEN).json({
      code: HttpCode.FORBIDDEN,
      error: "Forbidden",
      data: null,
    } satisfies ApiResponse<null>);
  }

  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("X-Accel-Buffering", "no");
  res.flushHeaders();

  roomEventBus.subscribe(req.params.id, res);

  const snapshot = await roomService.getWithMembers(req.params.id);
  res.write(
    `event: ${ROOM_SSE_EVENTS.INIT}\ndata: ${JSON.stringify(snapshot)}\n\n`,
  );

  const hb = setInterval(() => {
    try {
      res.write(": ping\n\n");
    } catch {}
  }, 20_000);

  req.on("close", () => {
    clearInterval(hb);
    roomEventBus.unsubscribe(req.params.id, res);
  });
});

roomsRouter.get("/:id", async (req, res) => {
  const data = await roomService.getWithMembers(req.params.id);
  res.json({
    code: HttpCode.OK,
    error: null,
    data,
  } satisfies ApiResponse<RoomWithMembers>);
});

roomsRouter.post("/:id/start", authorize("room:start"), async (req, res) => {
  const user = getUser(req);
  const room = await roomService.start(req.params.id, user.id);
  loggingService.log({
    event: "room:started",
    level: "info",
    userId: user.id,
    metadata: { room_id: room.id },
  });

  roomEventBus.publish(req.params.id, ROOM_SSE_EVENTS.ROOM_STARTED, {
    started_at: room.started_at,
  });

  res.json({
    code: HttpCode.OK,
    error: null,
    data: room,
  } satisfies ApiResponse<Room>);
});

roomsRouter.delete("/:id/leave", async (req, res) => {
  const user = getUser(req);

  const memberDetail = await roomService.getMemberDetail(
    req.params.id,
    user.id,
  );
  if (memberDetail?.game_session_id) {
    await gameService.abandon({ sessionId: memberDetail.game_session_id });
    const roomCompleted = await roomService.reconcileRoom(req.params.id);
    if (roomCompleted) {
      roomEventBus.publish(req.params.id, ROOM_SSE_EVENTS.ROOM_COMPLETED, {
        ended_at: new Date().toISOString(),
      });
    }
  }

  const { removed, roomStatus } = await roomService.leave(
    req.params.id,
    user.id,
  );

  if (removed) {
    roomEventBus.publish(req.params.id, ROOM_SSE_EVENTS.MEMBER_LEFT, {
      player_id: user.id,
    });

    if (roomStatus === "in_progress" && !memberDetail?.game_session_id) {
      const roomCompleted = await roomService.reconcileRoom(req.params.id);
      if (roomCompleted) {
        roomEventBus.publish(req.params.id, ROOM_SSE_EVENTS.ROOM_COMPLETED, {
          ended_at: new Date().toISOString(),
        });
      }
    }
  }

  res.json({
    code: HttpCode.OK,
    error: null,
    data: null,
  } satisfies ApiResponse<null>);
});

roomsRouter.delete("/:id", authorize("room:cancel"), async (req, res) => {
  const user = getUser(req);
  await roomService.cancel(req.params.id, user.id);
  loggingService.log({
    event: "room:cancelled",
    level: "info",
    userId: user.id,
    metadata: { room_id: req.params.id },
  });

  roomEventBus.publish(req.params.id, ROOM_SSE_EVENTS.ROOM_CANCELLED, {});

  res.json({
    code: HttpCode.OK,
    error: null,
    data: null,
  } satisfies ApiResponse<null>);
});
