import { useState } from "react";

export function useCursor() {
  const [stack, setStack] = useState<(number | undefined)[]>([undefined]);
  return {
    current: stack[stack.length - 1],
    pageIndex: stack.length - 1,
    hasPrev: stack.length > 1,
    next: (cursor: number) => setStack((p) => [...p, cursor]),
    prev: () => setStack((p) => p.slice(0, -1)),
    reset: () => setStack([undefined]),
  };
}
