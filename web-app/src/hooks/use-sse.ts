import { createParser } from "eventsource-parser";
import { useEffect, useRef } from "react";

const SSE_MAX_RETRIES = 5;

type SseHandlers<T> = Partial<{
  [K in keyof T & string]: (data: T[K]) => void;
}>;

type SseOptions = {
  onError?: (status: number) => void;
};

export function useSse<T extends Record<string, unknown>>(
  url: string | null,
  handlers: SseHandlers<T>,
  options?: SseOptions,
): void {
  const handlersRef = useRef(handlers);
  handlersRef.current = handlers;

  const onErrorRef = useRef(options?.onError);
  onErrorRef.current = options?.onError;

  useEffect(() => {
    if (!url) return;

    const abortController = new AbortController();
    let retryCount = 0;
    let retryTimer: ReturnType<typeof setTimeout> | null = null;

    const connect = async () => {
      try {
        const response = await fetch(url, {
          credentials: "include",
          signal: abortController.signal,
          headers: { Accept: "text/event-stream" },
        });

        if (!response.ok) {
          onErrorRef.current?.(response.status);
          return;
        }

        if (!response.body) return;

        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        const parser = createParser({
          onEvent(event) {
            if (!event.event) return;
            try {
              const data = JSON.parse(event.data);
              const handler = handlersRef.current[event.event as keyof T & string];
              handler?.(data);
            } catch {}
          },
        });

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          retryCount = 0;
          parser.feed(decoder.decode(value, { stream: true }));
        }
      } catch (err) {
        if ((err as Error).name === "AbortError") return;
      }

      if (abortController.signal.aborted) return;

      if (retryCount >= SSE_MAX_RETRIES) {
        onErrorRef.current?.(-1);
        return;
      }

      const delay = Math.min(1000 * 2 ** retryCount, 30_000);
      retryCount++;
      retryTimer = setTimeout(connect, delay);
    };

    abortController.signal.addEventListener("abort", () => {
      if (retryTimer) clearTimeout(retryTimer);
    });

    connect();
    return () => abortController.abort();
  }, [url]);
}
