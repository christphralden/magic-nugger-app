import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type { RoomSSEPayloads } from "@magic-nugger-app/shared";
import { useSse } from "./use-sse";

type RoomSseHandlers = Partial<{
  [K in keyof RoomSSEPayloads]: (data: RoomSSEPayloads[K]) => void;
}>;

type RoomSseOptions = {
  onError?: (status: number) => void;
};

export function useRoomSse(
  roomId: string | null,
  handlers: RoomSseHandlers,
  options?: RoomSseOptions,
): void {
  const url = roomId
    ? `${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/events`
    : null;
  useSse<RoomSSEPayloads>(url, handlers, options);
}
