import { getDb, tx } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";
import type {
  Room,
  RoomWithMembers,
  RoomMemberDetail,
  RequestCreateRoom,
} from "@magic-nugger-app/shared";
import { v4 as uuidv4 } from "uuid";

export const roomService = {
  async create(hostId: string, body: RequestCreateRoom): Promise<Room> {
    return tx(async () => {
      const inviteCode = uuidv4().slice(0, 8).toUpperCase();
      const { rows } = await getDb().query<Room>(
        `INSERT INTO rooms
          (host_id, level_id, type, invite_code, max_players)
         VALUES ($1, $2, 'pvp', $3, $4)
         RETURNING
          id, host_id, level_id, type, status, invite_code,
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
    });
  },

  async join(playerId: string, inviteCode: string): Promise<Room> {
    return tx(async () => {
      const { rows } = await getDb().query<Room>(
        `SELECT
          id, host_id, level_id, type, status, invite_code,
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
        `SELECT COUNT(*) AS count FROM room_members WHERE room_id = $1 AND deleted_at IS NULL`,
        [room.id],
      );

      if (Number(countRows[0].count) >= room.max_players) {
        throw new AppError(HttpCode.CONFLICT, "Room is full");
      }

      await getDb().query(
        `INSERT INTO room_members (room_id, player_id) VALUES ($1, $2)
         ON CONFLICT (room_id, player_id) DO UPDATE
           SET deleted_at = NULL, joined_at = now()
           WHERE room_members.deleted_at IS NOT NULL`,
        [room.id, playerId],
      );

      return room;
    });
  },

  async getById(roomId: string): Promise<Room> {
    const { rows } = await getDb().query<Room>(
      `SELECT
        id, host_id, level_id, type, status, invite_code,
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
       WHERE rm.room_id = $1 AND rm.deleted_at IS NULL
       ORDER BY rm.joined_at ASC`,
      [roomId],
    );

    return { room, members: rows };
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
        id, host_id, level_id, type, status, invite_code,
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
       WHERE room_id = $1 AND player_id = $2 AND deleted_at IS NULL`,
      [roomId, playerId, sessionId],
    );
  },

  async reconcileRoom(roomId: string): Promise<boolean> {
    const { rows } = await getDb().query<{ count: string }>(
      `SELECT COUNT(*) AS count
       FROM room_members rm
       LEFT JOIN game_sessions gs ON gs.id = rm.game_session_id
       WHERE rm.room_id = $1
         AND rm.deleted_at IS NULL
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
       WHERE rm.room_id = $1 AND rm.player_id = $2 AND rm.deleted_at IS NULL`,
      [roomId, playerId],
    );
    return rows[0] ?? null;
  },

  async isMember(roomId: string, playerId: string): Promise<boolean> {
    const { rows } = await getDb().query(
      `SELECT 1 FROM room_members WHERE room_id = $1 AND player_id = $2 AND deleted_at IS NULL`,
      [roomId, playerId],
    );
    return rows.length > 0;
  },

  async leave(
    roomId: string,
    playerId: string,
  ): Promise<{ removed: boolean; roomStatus: string | null }> {
    return tx(async () => {
      const { rows } = await getDb().query<{ status: string }>(
        `SELECT r.status
         FROM room_members rm
         JOIN rooms r ON r.id = rm.room_id
         WHERE rm.room_id = $1 AND rm.player_id = $2 AND rm.deleted_at IS NULL`,
        [roomId, playerId],
      );
      if (!rows[0]) return { removed: false, roomStatus: null };

      const { rowCount } = await getDb().query(
        `UPDATE room_members SET deleted_at = now()
         WHERE room_id = $1 AND player_id = $2 AND deleted_at IS NULL`,
        [roomId, playerId],
      );
      return { removed: (rowCount ?? 0) > 0, roomStatus: rows[0].status };
    });
  },

  async cancel(roomId: string, playerId: string): Promise<void> {
    return tx(async () => {
      const { rows: check } = await getDb().query<{ host_id: string }>(
        `SELECT host_id FROM rooms WHERE id = $1`,
        [roomId],
      );
      if (!check[0]) throw new AppError(HttpCode.NOT_FOUND, "Room not found");
      if (check[0].host_id !== playerId) {
        throw new AppError(HttpCode.FORBIDDEN, "Forbidden");
      }

      await getDb().query(
        `UPDATE rooms
         SET status = 'cancelled', ended_at = now(), updated_at = now()
         WHERE id = $1 AND status IN ('waiting', 'in_progress')`,
        [roomId],
      );

      await getDb().query(
        `UPDATE room_members SET deleted_at = now()
         WHERE room_id = $1 AND deleted_at IS NULL`,
        [roomId],
      );
    });
  },
};
