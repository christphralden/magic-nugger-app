export const GameSessionConfig = {
  RESUME_WINDOW_MS: parseInt(process.env.GAME_SESSION_RESUME_WINDOW_MS ?? "1800000", 10),
};
