import { getDb } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";
import type {
  Room,
  RoomWithMembers,
  RoomMemberDetail,
  RequestCreateRoom,
  RequestCreateClassroomRoom,
} from "@magic-nugger-app/shared";
import { v4 as uuidv4 } from "uuid";

export const roomService = {
  async create(hostId: string, body: RequestCreateRoom): Promise<Room> {
    const inviteCode = uuidv4().slice(0, 8).toUpperCase();
    const { rows } = await getDb().query<Room>(
      `INSERT INTO rooms
        (host_id, level_id, type, invite_code, max_players)
       VALUES ($1, $2, 'pvp', $3, $4)
       RETURNING
        id, host_id, classroom_id, level_id, type, status, invite_code,
        max_players, started_at, ended_at, created_at, updated_at
      `,
      [hostId, body.level_id, inviteCode, body.max_players ?? 10],
    );
    const room = rows[0];

    await getDb().query(
      `INSERT INTO room_members (room_id, player_id) VALUES ($1, $2)`,
      [room.id, hostId],
    );

    return room;
  },

  async createClassroomRoom(
    hostId: string,
    body: RequestCreateClassroomRoom,
  ): Promise<Room> {
    const { rows: classroomRows } = await getDb().query<{ teacher_id: string }>(
      `SELECT teacher_id FROM classrooms WHERE id = $1 AND is_active = true`,
      [body.classroom_id],
    );
    if (!classroomRows[0]) {
      throw new AppError(HttpCode.NOT_FOUND, "Classroom not found");
    }
    if (classroomRows[0].teacher_id !== hostId) {
      throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
    }

    const { rows: activeRows } = await getDb().query<{ id: string }>(
      `SELECT id FROM rooms
       WHERE classroom_id = $1 AND status IN ('waiting', 'in_progress')
       LIMIT 1`,
      [body.classroom_id],
    );
    if (activeRows[0]) {
      throw new AppError(
        HttpCode.CONFLICT,
        "An active room already exists for this classroom",
      );
    }

    const inviteCode = uuidv4().slice(0, 8).toUpperCase();
    const { rows } = await getDb().query<Room>(
      `INSERT INTO rooms
        (host_id, classroom_id, level_id, type, invite_code, max_players)
       VALUES ($1, $2, $3, 'classroom', $4, $5)
       RETURNING
        id, host_id, classroom_id, level_id, type, status, invite_code,
        max_players, started_at, ended_at, created_at, updated_at
      `,
      [
        hostId,
        body.classroom_id,
        body.level_id,
        inviteCode,
        body.max_players ?? 10,
      ],
    );
    const room = rows[0];

    await getDb().query(
      `INSERT INTO room_members (room_id, player_id) VALUES ($1, $2)`,
      [room.id, hostId],
    );

    return room;
  },

  async join(playerId: string, inviteCode: string): Promise<Room> {
    const { rows } = await getDb().query<Room>(
      `SELECT
        id, host_id, classroom_id, level_id, type, status, invite_code,
        max_players, started_at, ended_at, created_at, updated_at
       FROM rooms
       WHERE invite_code = $1`,
      [inviteCode],
    );
    if (!rows[0]) {
      throw new AppError(HttpCode.NOT_FOUND, "Invalid invite code");
    }
    const room = rows[0];

    if (room.status === "cancelled" || room.status === "completed") {
      throw new AppError(
        HttpCode.NOT_FOUND,
        "Room has already ended, you can create a new one",
      );
    }

    if (room.status === "in_progress") {
      throw new AppError(
        HttpCode.CONFLICT,
        "Room has already started, join a different room or create a new one",
      );
    }

    const { rows: countRows } = await getDb().query<{ count: string }>(
      `SELECT COUNT(*) AS count FROM room_members WHERE room_id = $1`,
      [room.id],
    );

    if (Number(countRows[0].count) >= room.max_players) {
      throw new AppError(HttpCode.CONFLICT, "Room is full");
    }

    await getDb().query(
      `INSERT INTO room_members (room_id, player_id) VALUES ($1, $2)
       ON CONFLICT DO NOTHING`,
      [room.id, playerId],
    );

    return room;
  },

  async getById(roomId: string): Promise<Room> {
    const { rows } = await getDb().query<Room>(
      `SELECT
        id, host_id, classroom_id, level_id, type, status, invite_code,
        max_players, started_at, ended_at, created_at, updated_at
       FROM rooms WHERE id = $1`,
      [roomId],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Room not found");
    return rows[0];
  },

  async getWithMembers(roomId: string): Promise<RoomWithMembers> {
    const room = await roomService.getById(roomId);

    const { rows } = await getDb().query<RoomMemberDetail>(
      `SELECT
        rm.player_id,
        p.username,
        p.display_name,
        p.avatar_url,
        rm.game_session_id,
        gs.status AS session_status,
        rm.joined_at
       FROM room_members rm
       JOIN players p ON p.id = rm.player_id
       LEFT JOIN game_sessions gs ON gs.id = rm.game_session_id
       WHERE rm.room_id = $1
       ORDER BY rm.joined_at ASC`,
      [roomId],
    );

    return { room, members: rows };
  },

  async getActiveForPlayer(playerId: string): Promise<Room[]> {
    const { rows } = await getDb().query<Room>(
      `SELECT
        r.id, r.host_id, r.classroom_id, r.level_id, r.type, r.status,
        r.invite_code, r.max_players, r.started_at, r.ended_at,
        r.created_at, r.updated_at
       FROM rooms r
       JOIN room_members rm ON rm.room_id = r.id
       WHERE rm.player_id = $1
         AND r.status IN ('waiting', 'in_progress')
       ORDER BY r.created_at DESC`,
      [playerId],
    );
    return rows;
  },

  async start(roomId: string, hostId: string): Promise<Room> {
    const { rows: check } = await getDb().query<{ host_id: string }>(
      `SELECT host_id FROM rooms WHERE id = $1`,
      [roomId],
    );
    if (!check[0]) throw new AppError(HttpCode.NOT_FOUND, "Room not found");
    if (check[0].host_id !== hostId) {
      throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
    }

    const { rows } = await getDb().query<Room>(
      `UPDATE rooms
       SET status = 'in_progress', started_at = now(), updated_at = now()
       WHERE id = $1 AND status = 'waiting'
       RETURNING
        id, host_id, classroom_id, level_id, type, status, invite_code,
        max_players, started_at, ended_at, created_at, updated_at`,
      [roomId],
    );
    if (!rows[0]) {
      throw new AppError(HttpCode.CONFLICT, "Room is not in waiting state");
    }
    return rows[0];
  },

  async end(roomId: string, hostId: string): Promise<void> {
    const { rows: check } = await getDb().query<{ host_id: string }>(
      `SELECT host_id FROM rooms WHERE id = $1`,
      [roomId],
    );
    if (!check[0]) throw new AppError(HttpCode.NOT_FOUND, "Room not found");
    if (check[0].host_id !== hostId) {
      throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
    }

    await getDb().query(
      `UPDATE rooms
       SET status = 'completed', ended_at = now(), updated_at = now()
       WHERE id = $1 AND status = 'in_progress'`,
      [roomId],
    );
  },

  async linkMemberSession({
    roomId,
    playerId,
    sessionId,
  }: {
    roomId: string;
    playerId: string;
    sessionId: string;
  }): Promise<void> {
    await getDb().query(
      `UPDATE room_members
       SET game_session_id = $3
       WHERE room_id = $1 AND player_id = $2`,
      [roomId, playerId, sessionId],
    );
  },

  async checkAndCompleteRoom(roomId: string): Promise<boolean> {
    const { rows } = await getDb().query<{ count: string }>(
      `SELECT COUNT(*) AS count
       FROM room_members rm
       LEFT JOIN game_sessions gs ON gs.id = rm.game_session_id
       WHERE rm.room_id = $1
         AND (rm.game_session_id IS NULL OR gs.status = 'in_progress')`,
      [roomId],
    );
    if (Number(rows[0].count) === 0) {
      const { rowCount } = await getDb().query(
        `UPDATE rooms
         SET status = 'completed', ended_at = now(), updated_at = now()
         WHERE id = $1 AND status = 'in_progress'`,
        [roomId],
      );
      return (rowCount ?? 0) > 0;
    }
    return false;
  },

  async getMemberDetail(
    roomId: string,
    playerId: string,
  ): Promise<RoomMemberDetail | null> {
    const { rows } = await getDb().query<RoomMemberDetail>(
      `SELECT
         rm.player_id,
         p.username,
         p.display_name,
         p.avatar_url,
         rm.game_session_id,
         gs.status AS session_status,
         rm.joined_at
       FROM room_members rm
       JOIN players p ON p.id = rm.player_id
       LEFT JOIN game_sessions gs ON gs.id = rm.game_session_id
       WHERE rm.room_id = $1 AND rm.player_id = $2`,
      [roomId, playerId],
    );
    return rows[0] ?? null;
  },

  async isMember(roomId: string, playerId: string): Promise<boolean> {
    const { rows } = await getDb().query(
      `SELECT 1 FROM room_members WHERE room_id = $1 AND player_id = $2`,
      [roomId, playerId],
    );
    return rows.length > 0;
  },

  async leave(
    roomId: string,
    playerId: string,
  ): Promise<{ removed: boolean; roomStatus: string | null }> {
    const { rows } = await getDb().query<{
      status: string;
      game_session_id: string | null;
    }>(
      `SELECT r.status, rm.game_session_id
       FROM room_members rm
       JOIN rooms r ON r.id = rm.room_id
       WHERE rm.room_id = $1 AND rm.player_id = $2`,
      [roomId, playerId],
    );
    if (!rows[0]) return { removed: false, roomStatus: null };

    const { status, game_session_id } = rows[0];
    if (game_session_id !== null) return { removed: false, roomStatus: status };

    const { rowCount } = await getDb().query(
      `DELETE FROM room_members WHERE room_id = $1 AND player_id = $2 AND game_session_id IS NULL`,
      [roomId, playerId],
    );
    return { removed: (rowCount ?? 0) > 0, roomStatus: status };
  },

  async cancel(roomId: string, playerId: string): Promise<void> {
    const { rows: check } = await getDb().query<{
      host_id: string;
      classroom_id: string | null;
    }>(`SELECT host_id, classroom_id FROM rooms WHERE id = $1`, [roomId]);
    if (!check[0]) throw new AppError(HttpCode.NOT_FOUND, "Room not found");

    const isHost = check[0].host_id === playerId;

    if (!isHost && check[0].classroom_id) {
      const { rows: teacherRows } = await getDb().query<{ teacher_id: string }>(
        `SELECT teacher_id FROM classrooms WHERE id = $1`,
        [check[0].classroom_id],
      );
      if (!teacherRows[0] || teacherRows[0].teacher_id !== playerId) {
        throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
      }
    } else if (!isHost) {
      throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
    }

    await getDb().query(
      `UPDATE rooms
       SET status = 'cancelled', ended_at = now(), updated_at = now()
       WHERE id = $1 AND status IN ('waiting', 'in_progress')`,
      [roomId],
    );
  },
};
