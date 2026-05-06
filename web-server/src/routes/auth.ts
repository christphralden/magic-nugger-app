import { Router } from "express";
import passport from "passport";
import bcrypt from "bcrypt";
import { validate } from "@/middleware/validate";
import { authenticate } from "@/middleware/authenticate";
import { toResponsePlayer } from "@/dto/player.dto";
import {
  RequestCreatePlayerSchema,
  RequestLoginSchema,
  ErrorCode,
} from "@magic-nugger-app/shared";
import type { ApiResponse, ResponsePlayer } from "@magic-nugger-app/shared";
import { getDb } from "@/db/transaction-context";

export const authRouter = Router();

authRouter.post(
  "/register",
  validate(RequestCreatePlayerSchema),
  async (req, res) => {
    const { username, email, password, display_name } = req.body;
    const hash = await bcrypt.hash(password, 12);

    const { rows } = await getDb().query<ResponsePlayer>(
      `INSERT INTO players 
        (
          username, 
          email, 
          display_name, 
          password_hash
        )
       VALUES ($1, $2, $3, $4)
       RETURNING id, username, display_name, current_elo, highest_level_unlocked, avatar_url`,
      [username, email, display_name ?? null, hash],
    );

    res.status(201).json({
      code: 201,
      error: null,
      data: rows[0],
    } satisfies ApiResponse<ResponsePlayer>);
  },
);

authRouter.post("/login", validate(RequestLoginSchema), (req, res, next) => {
  passport.authenticate("local", (err: unknown, user: Express.User) => {
    if (err || !user) {
      return res.status(401).json({
        code: ErrorCode.UNAUTHORIZED,
        error: "Invalid credentials",
        data: null,
      } satisfies ApiResponse<null>);
    }
    req.logIn(user, (loginErr) => {
      if (loginErr) return next(loginErr);
      const player = toResponsePlayer(user);
      if (!player) return next(new Error("user mapping failed"));
      res.json({
        code: 200,
        error: null,
        data: player,
      } satisfies ApiResponse<ResponsePlayer>);
    });
  })(req, res, next);
});

authRouter.get(
  "/oauth/google",
  passport.authenticate("google", { scope: ["profile", "email"] }),
);

authRouter.get(
  "/oauth/google/callback",
  passport.authenticate("google", {
    failureRedirect: "/",
    successRedirect: "/levels",
  }),
);

authRouter.use(authenticate);

authRouter.post("/logout", (req, res) => {
  req.logout(() => {
    res.json({
      code: 200,
      error: null,
      data: null,
    } satisfies ApiResponse<null>);
  });
});

authRouter.get("/me", (req, res) => {
  const player = toResponsePlayer(req.user);
  if (!player) {
    return;
  }
  res.json({
    code: 200,
    error: null,
    data: player,
  } satisfies ApiResponse<ResponsePlayer>);
});
