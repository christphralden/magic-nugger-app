import pg from "pg";

const { Pool } = pg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: Number(process.env.DB_POOL_MAX ?? 20),
  idleTimeoutMillis: Number(process.env.DB_POOL_IDLE_TIMEOUT_MS ?? 30000),
  connectionTimeoutMillis: Number(
    process.env.DB_POOL_CONNECTION_TIMEOUT_MS ?? 5000,
  ),
  query_timeout: Number(process.env.DB_QUERY_TIMEOUT_MS ?? 30000),
  ssl:
    process.env.DB_SSL_MODE === "require"
      ? { rejectUnauthorized: false }
      : false,
});

export type QueryRunner = {
  query<T extends pg.QueryResultRow = pg.QueryResultRow>(
    text: string,
    params?: unknown[],
  ): Promise<pg.QueryResult<T>>;
};

const makeRunner = (client: pg.Pool | pg.PoolClient): QueryRunner => ({
  query<T extends pg.QueryResultRow>(text: string, params?: unknown[]) {
    return client.query<T>(text, params);
  },
});

export const db = {
  pool,
  ...makeRunner(pool),
  async transaction<T>(fn: (trx: QueryRunner) => Promise<T>): Promise<T> {
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const result = await fn(makeRunner(client));
      await client.query("COMMIT");
      return result;
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  },
};
