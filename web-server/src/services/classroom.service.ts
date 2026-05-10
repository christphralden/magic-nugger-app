import { getDb } from "@/db/transaction-context.js";
import { AppError } from "@/errors/app-error.js";
import { HttpCode } from "@magic-nugger-app/shared";
import type {
  Classroom,
  RequestCreateClassroom,
  RequestUpdateClassroom,
} from "@magic-nugger-app/shared";
import { v4 as uuidv4 } from "uuid";

export const classroomService = {
  async create(
    teacherId: string,
    body: RequestCreateClassroom,
  ): Promise<Classroom> {
    const inviteCode = uuidv4().slice(0, 8).toUpperCase();
    const { rows } = await getDb().query<Classroom>(
      `INSERT INTO classrooms 
        (name, description, teacher_id, visibility, starting_elo,
        elo_cap, invite_code)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING 
        name, description, teacher_id, visibility, starting_elo,
        elo_cap, invite_code
      `,
      [
        body.name,
        body.description ?? null,
        teacherId,
        body.visibility,
        body.starting_elo ?? 0,
        body.elo_cap ?? null,
        inviteCode,
      ],
    );
    return rows[0];
  },

  async get(userId: string): Promise<Classroom[]> {
    const { rows } = await getDb().query<Classroom>(
      `SELECT c.* from classrooms c
      JOIN classroom_members cm on c.id = cm.classroom_id
      WHERE
        c.is_active = true
        AND (
          c.teacher_id = $1
          OR cm.player_id = $1
        )
      `,
      [userId],
    );
    return rows;
  },

  async getById(id: string): Promise<Classroom> {
    const { rows } = await getDb().query<Classroom>(
      `SELECT * 
      FROM classrooms 
      WHERE 
        id = $1 
        AND is_active = true
      `,
      [id],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Classroom not found");
    return rows[0];
  },

  async update(id: string, body: RequestUpdateClassroom): Promise<Classroom> {
    const { rows } = await getDb().query<Classroom>(
      `UPDATE classrooms SET
        name = COALESCE($2, name),
        description = COALESCE($3, description),
        visibility = COALESCE($4, visibility),
        starting_elo = COALESCE($5, starting_elo),
        elo_cap = COALESCE($6, elo_cap),
        updated_at = now()
      WHERE 
        id = $1 
        AND is_active = true
      RETURNING 
        id, name, description, teacher_id, visibility, starting_elo,
        elo_cap, invite_code, is_active, created_at, updated_at
      `,
      [
        id,
        body.name ?? null,
        body.description ?? null,
        body.visibility ?? null,
        body.starting_elo ?? null,
        body.elo_cap ?? null,
      ],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Classroom not found");
    return rows[0];
  },

  async delete(id: string): Promise<void> {
    const { rowCount } = await getDb().query(
      `UPDATE classrooms 
      SET
        is_active = false, 
        updated_at = now() 
      WHERE id = $1
      `,
      [id],
    );
    if (!rowCount)
      throw new AppError(HttpCode.NOT_FOUND, "Classroom not found");
  },

  async join(playerId: string, inviteCode: string): Promise<void> {
    const { rows } = await getDb().query<{ id: string; starting_elo: number }>(
      `SELECT 
        id, starting_elo 
      FROM classrooms 
      WHERE 
        invite_code = $1 
        AND is_active = true
      `,
      [inviteCode],
    );
    if (!rows[0]) throw new AppError(HttpCode.NOT_FOUND, "Invalid invite code");

    await getDb().query(
      `INSERT INTO classroom_members 
        (classroom_id, player_id, classroom_elo)
       VALUES ($1, $2, $3)
       ON CONFLICT (classroom_id, player_id) DO NOTHING
      `,
      [rows[0].id, playerId, rows[0].starting_elo],
    );
  },

  async leave(playerId: string, classroomId: string): Promise<void> {
    await getDb().query(
      `DELETE FROM classroom_members 
      WHERE 
        classroom_id = $1 
        AND player_id = $2
      `,
      [classroomId, playerId],
    );
  },
};
