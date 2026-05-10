import { Request } from "express";

export function getClientIp(req: Request): string {
  return (req.ip ?? req.socket.remoteAddress ?? "0.0.0.0").replace(
    /^::ffff:/,
    "",
  );
}

export function getUserAgent(req: Request): string | null {
  return req.headers["user-agent"] ?? null;
}
