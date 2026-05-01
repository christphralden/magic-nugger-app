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
  const dir = path.join(__dirname, "migrations", "apply");
  const files = (await fs.readdir(dir))
    .filter((f) => f.endsWith(".sql"))
    .sort();

  for (const file of files) {
    const patchName = file.replace(".sql", "");
    if (await isApplied(client, patchName)) {
      console.log(`\t[migration] - skip\t${patchName}`);
      continue;
    }

    console.log(`[migration] - apply\t${patchName}`);
    const sql = await fs.readFile(path.join(dir, file), "utf8");
    await client.query("BEGIN");
    try {
      await client.query(sql);
      await client.query("COMMIT");
      console.log(`\t[migration] - ok\t${patchName}`);
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    }
  }
}

async function runDown(client) {
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

  console.log(`[migration] - rollback\t${patchName}`);
  const sql = await fs.readFile(filePath, "utf8");
  await client.query("BEGIN");
  try {
    await client.query(sql);
    await client.query("COMMIT");
    console.log(`\t[migration] - ok\t${patchName}`);
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  }
}

async function main() {
  const cmd = process.argv[2];
  if (!["up", "down"].includes(cmd)) {
    console.log("usage: node db/runner.mjs [up|down]");
    process.exit(1);
  }

  const client = new Client({ connectionString: process.env.DATABASE_URL });
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
