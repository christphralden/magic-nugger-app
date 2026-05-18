import type { Response } from "express";
import type { RoomSSEEventKey } from "@magic-nugger-app/shared";

const subscribers = new Map<string, Set<Response>>();

const writeEvent = (res: Response, type: RoomSSEEventKey, data: unknown): void => {
  try {
    res.write(`event: ${type}\ndata: ${JSON.stringify(data)}\n\n`);
  } catch {}
};

export const roomEventBus = {
  subscribe(roomId: string, res: Response): void {
    if (!subscribers.has(roomId)) subscribers.set(roomId, new Set());
    subscribers.get(roomId)!.add(res);
  },

  unsubscribe(roomId: string, res: Response): void {
    subscribers.get(roomId)?.delete(res);
    if (subscribers.get(roomId)?.size === 0) subscribers.delete(roomId);
  },

  publish(roomId: string, type: RoomSSEEventKey, data: unknown): void {
    const subs = subscribers.get(roomId);
    if (!subs) return;
    for (const res of subs) writeEvent(res, type, data);
  },
};
