export function getClientIp(req: express.Request): string {
  return (req.ip ?? req.socket.remoteAddress ?? "0.0.0.0").replace(
    /^::ffff:/,
    "",
  );
}
