import "./config/passport";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import session from "express-session";
import passport from "passport";
import connectPgSimple from "connect-pg-simple";
import { db } from "@/db/client";
import { errorHandler } from "@/middleware/error-handler";
import { authRouter } from "@/routes/auth";
import { playersRouter } from "@/routes/players";
import { levelsRouter } from "@/routes/levels";
import { gameRouter } from "@/routes/game";
// import { leaderboardRouter } from "@/routes/leaderboard";
// import { classroomsRouter } from "@/routes/classrooms";
import { adminRouter } from "@/routes/admin";
import { logsRouter } from "@/routes/logs";
import { getClientIp } from "@/utils/connectivity";
import { audit } from "@/middleware/audit";
import { internalRouter } from "./routes/internal";

const isLocalEnvironment = process.env.ENVIRONMENT === "local";
const isProd = process.env.NODE_ENV === "production";

const app = express();

if (isProd) {
  app.set("trust proxy", 1);
}

if (isLocalEnvironment) {
  app.use(
    cors({
      origin: process.env.CORS_ORIGIN ?? true,
      credentials: true,
    }),
  );
}

app.use(helmet({ contentSecurityPolicy: false }));

app.use(express.json({ limit: "1mb" }));

if (!isLocalEnvironment) {
  const limiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 minute
    limit: process.env.RRM_LIMIT ? Number(process.env.RPM_LIMIT) : 3000,
    standardHeaders: "draft-7",
    legacyHeaders: false,
    keyGenerator: (req) => getClientIp(req),
    message: {
      error: {
        code: "RATE_LIMIT_EXCEEDED",
        message: "Too many requests",
      },
    },
  });
  app.use(limiter);
}

const PostgresStore = connectPgSimple(session);

app.use(
  session({
    store: new PostgresStore({
      pool: db.pool,
      tableName: "session",
    }),
    secret: isProd
      ? (process.env.SESSION_SECRET ??
        (() => {
          throw new Error("SESSION_SECRET is required in production");
        })())
      : (process.env.SESSION_SECRET ?? "dev-secret"),
    resave: false,
    saveUninitialized: false,
    cookie: {
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      secure: isProd,
      httpOnly: true,
      sameSite: "lax",
    },
    rolling: true,
  }),
);

app.use(passport.initialize());
app.use(passport.session());
app.use(audit);

app.use("/api/v1/internal", internalRouter);
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/players", playersRouter);
app.use("/api/v1/levels", levelsRouter);
app.use("/api/v1/game", gameRouter);
// app.use("/api/v1/leaderboard", leaderboardRouter);
// app.use("/api/v1/classrooms", classroomsRouter);
app.use("/api/v1/admin", adminRouter);
app.use("/api/v1/logs", logsRouter);
app.use(errorHandler);

export { app };
