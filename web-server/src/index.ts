import "dotenv/config";
import { app } from "@/app.js";
import { db } from "@/db/client.js";
import { formatError } from "@/utils/errors.js";
import { ErrorCode } from "@magic-nugger-app/shared";

if (!process.env.PORT) {
  throw new Error("env {{PORT}} is not set");
}
if (!process.env.ENVIRONMENT) {
  throw new Error("env {{ENVIRONMENT}} is not set");
}

const PORT = Number(process.env.PORT);
const isLocalEnvironment = process.env.ENVIRONMENT === "local";

app.get("/health", async (_req, res) => {
  try {
    await db.query("SELECT 1");
    res.status(ErrorCode.OK).json({
      code: ErrorCode.OK,
      error: null,
      data: {
        message: "ok",
      },
    });
  } catch (error) {
    const errorMessage = formatError(error);
    if (errorMessage.includes("ECONNREFUSED")) {
      res.status(ErrorCode.SERVICE_UNAVAILABLE).json({
        code: ErrorCode.SERVICE_UNAVAILABLE,
        error: `Failed to establish connection to database
If you are running locally don't forget to run db 
'docker compose --env-file=<path-to-env> -f docker-compose.dev.yml up -d magic-nugger-postgres'
If you are in prod check if magic-nugger-postgres is healthy`,
        data: null,
      });
    } else {
      res.status(ErrorCode.SERVICE_UNAVAILABLE).json({
        code: ErrorCode.SERVICE_UNAVAILABLE,
        error: formatError(error),
        data: null,
      });
    }
  }
});

const server = app.listen(PORT, () => {
  console.log(`Server listening on port :${PORT}`);
});

server.timeout = 30000;
server.keepAliveTimeout = 65000;
server.headersTimeout = 66000;

function gracefulShutdown(signal: string) {
  console.log(
    `[web-server][log] Received ${signal}. Shutting down gracefully...`,
  );
  server.close(() => {
    console.log("[web-server][log] HTTP server closed.");
    db.pool.end().then(() => {
      console.log("[web-server][log] Database pool closed.");
      process.exit(0);
    });
  });
}

if (!isLocalEnvironment) {
  process.once("SIGTERM", () => gracefulShutdown("SIGTERM"));
  process.once("SIGINT", () => gracefulShutdown("SIGINT"));
}
