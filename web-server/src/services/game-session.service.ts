import { getDb } from "@/db/transaction-context.js";
import type { GameSession } from "@magic-nugger-app/shared";

export const gameSessionService = {
  async getActiveByPlayerId({
    userId,
  }: {
    userId: string;
  }): Promise<GameSession | null> {
    const { rows } = await getDb().query<GameSession>(
      `SELECT 
        id, player_id, level_id, status, score,
        max_answers, elo_before, elo_after, elo_delta, correct_count, 
        incorrect_count, max_streak, current_streak, started_at, ended_at,
        client_ip, user_agent 
      FROM game_sessions
      WHERE 
        player_id = $1 
        AND status = 'in_progress'
      ORDER BY started_at DESC LIMIT 1`,
      [userId],
    );
    return rows[0] ?? null;
  },

  async getActiveById({
    sessionId,
  }: {
    sessionId: string;
  }): Promise<GameSession | null> {
    const { rows } = await getDb().query<GameSession>(
      `SELECT 
        id, player_id, level_id, status, score,
        max_answers, elo_before, elo_after, elo_delta, 
        correct_count, incorrect_count, max_streak, current_streak,
        started_at, ended_at, client_ip, user_agent  
      FROM game_sessions 
      WHERE 
        id = $1 
        AND status = 'in_progress'
      `,
      [sessionId],
    );
    return rows[0] ?? null;
  },

  async create({
    userId,
    levelId,
    currentElo,
    maxAnswers,
    ip,
    userAgent,
  }: {
    userId: string;
    levelId: number;
    currentElo: number;
    maxAnswers: number;
    ip: string;
    userAgent: string | null;
  }): Promise<GameSession> {
    const { rows } = await getDb().query<GameSession>(
      `INSERT INTO game_sessions 
        (player_id, level_id, elo_before, max_answers, client_ip, user_agent)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING 
        id, player_id, level_id, status, score,
        max_answers, elo_before, elo_after, elo_delta, correct_count, 
        incorrect_count, max_streak, current_streak, started_at, ended_at,
        client_ip, user_agent
      `,
      [userId, levelId, currentElo, maxAnswers, ip, userAgent],
    );
    return rows[0];
  },

  async abandon({ sessionId }: { sessionId: string }): Promise<void> {
    await getDb().query(
      `UPDATE game_sessions 
      SET 
        status = 'abandoned', 
        ended_at = now() 
      WHERE id = $1
      `,
      [sessionId],
    );
  },

  async finalize({
    sessionId,
    status,
    finalElo,
  }: {
    sessionId: string;
    status: "completed" | "failed";
    finalElo: number;
  }): Promise<void> {
    await getDb().query(
      `UPDATE game_sessions
      SET 
        status = $2, 
        elo_after = $3, 
        ended_at = now() 
      WHERE id = $1`,
      [sessionId, status, finalElo],
    );
  },

  async updateStats({
    sessionId,
    score,
    correctCount,
    incorrectCount,
    currentStreak,
    maxStreak,
    eloDelta,
  }: {
    sessionId: string;
    score: number;
    correctCount: number;
    incorrectCount: number;
    currentStreak: number;
    maxStreak: number;
    eloDelta: number;
  }): Promise<void> {
    await getDb().query(
      `UPDATE game_sessions SET
        score = $2,
        correct_count = $3,
        incorrect_count = $4,
        current_streak = $5,
        max_streak = $6,
        elo_delta = $7
       WHERE id = $1
      `,
      [
        sessionId,
        score,
        correctCount,
        incorrectCount,
        currentStreak,
        maxStreak,
        eloDelta,
      ],
    );
  },

  async insertAnswer({
    sessionId,
    isCorrect,
    delta,
    timeTakenMs,
  }: {
    sessionId: string;
    isCorrect: boolean;
    delta: number;
    timeTakenMs?: number;
  }): Promise<void> {
    await getDb().query(
      `INSERT INTO session_answers 
        (session_id, is_correct, elo_delta, time_taken_ms)
       VALUES ($1, $2, $3, $4)
      `,
      [sessionId, isCorrect, delta, timeTakenMs ?? null],
    );
  },
};
