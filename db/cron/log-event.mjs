#!/usr/bin/env node
import { Client } from "pg";

const [, , event, level, metaJson] = process.argv;
const host = process.env.POSTGRES_HOST ?? "localhost";
const connectionString = `postgresql://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${host}:5432/${process.env.POSTGRES_DB}`;

const client = new Client({ connectionString });
await client.connect();
try {
  await client.query(
    "INSERT INTO audit.log_events (event, level, metadata) VALUES ($1, $2, $3)",
    [event, level, metaJson ?? null],
  );
} finally {
  await client.end();
}
