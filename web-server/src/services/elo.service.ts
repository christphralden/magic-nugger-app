import { getDb } from "@/db/transaction-context.js";

export const eloService = {
  async append({
    userId,
    sessionId,
    eloBefore,
    eloAfter,
    delta,
    reason,
  }: {
    userId: string;
    sessionId: string;
    eloBefore: number;
    eloAfter: number;
    delta: number;
    reason: string;
  }): Promise<void> {
    await getDb().query(
      `INSERT INTO elo_history 
        (player_id, session_id, elo_before, elo_after, delta, reason)
       VALUES ($1, $2, $3, $4, $5, $6)
      `,
      [userId, sessionId, eloBefore, eloAfter, delta, reason],
    );
  },
};
