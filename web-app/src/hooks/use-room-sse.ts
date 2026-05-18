import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type { RoomSSEPayloads } from "@magic-nugger-app/shared";
import { useSse } from "./use-sse";

export function useRoomSse(roomId: string | null) {
  const url = roomId
    ? `${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/events`
    : null;
  return useSse<RoomSSEPayloads>(url);
}
