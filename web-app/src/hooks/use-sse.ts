import { createParser } from "eventsource-parser";
import { useCallback, useEffect, useRef } from "react";

export function useSse<T extends Record<string, unknown>>(url: string | null) {
  const handlersRef = useRef(new Map<string, (data: unknown) => void>());

  useEffect(() => {
    if (!url) return;

    const abortController = new AbortController();

    const connect = async () => {
      try {
        const response = await fetch(url, {
          credentials: "include",
          signal: abortController.signal,
          headers: { Accept: "text/event-stream" },
        });
        if (!response.ok || !response.body) return;

        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        const parser = createParser({
          onEvent(event) {
            if (!event.event) return;
            try {
              const data = JSON.parse(event.data);
              handlersRef.current.get(event.event)?.(data);
            } catch {}
          },
        });

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          parser.feed(decoder.decode(value, { stream: true }));
        }
      } catch (err) {
        if ((err as Error).name === "AbortError") return;
      }
    };

    connect();
    return () => abortController.abort();
  }, [url]);

  const register = useCallback(
    <K extends keyof T & string>(event: K, handler: (data: T[K]) => void) => {
      console.log("run");
      handlersRef.current.set(event, handler as (data: unknown) => void);
    },
    [],
  );

  const unregister = useCallback((event: string) => {
    handlersRef.current.delete(event);
  }, []);

  return { register, unregister };
}
