import { AsyncLocalStorage } from "async_hooks";
import { db } from "@/db/client.js";
import type { QueryRunner } from "@/db/client.js";

const dbAsyncStorage = new AsyncLocalStorage<QueryRunner>();

export const getDb = (): QueryRunner => dbAsyncStorage.getStore() ?? db;

export const tx = <T>(fn: () => Promise<T>): Promise<T> =>
  db.transaction((trx) => dbAsyncStorage.run(trx, fn)) satisfies Promise<T>;
