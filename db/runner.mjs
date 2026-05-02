#!/usr/bin/env node
import { Client } from "pg";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function isApplied(client, patchName) {
  try {
    const { rows } = await client.query(
      "SELECT 1 FROM _v.patches WHERE patch_name = $1",
      [patchName],
    );
    return rows.length > 0;
  } catch (err) {
    if (err.code === "42P01") return false;
    throw err;
  }
}

async function runUp(client) {
  console.log("[migration] run up\n\n");
  const dir = path.join(__dirname, "migrations", "apply");
  const files = (await fs.readdir(dir))
    .filter((f) => f.endsWith(".sql"))
    .sort();

  for (const file of files) {
    const patchName = file.replace(".sql", "");

    console.log(`=== ${patchName} ===`);
    if (await isApplied(client, patchName)) {
      console.log(`[migration] - skipped`);
      continue;
    }

    console.log(`[migration] - applied`);
    const sql = await fs.readFile(path.join(dir, file), "utf8");
    await client.query(sql);
    console.log(`[migration] - ok`);
  }
}

async function runDown(client) {
  console.log("[migration] run down\n\n");
  const { rows } = await client.query(
    "SELECT patch_name FROM _v.patches ORDER BY applied_at DESC LIMIT 1",
  );
  if (rows.length === 0) {
    console.log("[migration] - no patches to rollback");
    return;
  }

  const patchName = rows[0].patch_name;
  const filePath = path.join(
    __dirname,
    "migrations",
    "rollback",
    `${patchName}.sql`,
  );

  console.log(`=== ${patchName} ===`);
  const sql = await fs.readFile(filePath, "utf8");
  await client.query(sql);
  console.log(`[migration] - ok`);
}

async function main() {
  const cmd = process.argv[2];
  if (!["up", "down"].includes(cmd)) {
    console.log("usage: node db/runner.mjs [up|down]");
    process.exit(1);
  }

  const host = process.env.POSTGRES_HOST ?? "localhost";
  const connectionString = `postgresql://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${host}:5432/${process.env.POSTGRES_DB}`;
  const client = new Client({ connectionString });
  await client.connect();

  try {
    if (cmd === "up") await runUp(client);
    else await runDown(client);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
