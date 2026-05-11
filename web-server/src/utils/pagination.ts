import { CacheConfig } from "@/constants/cache";
import { CursorPagination } from "@magic-nugger-app/shared";
import type { ParsedQs } from "qs";

export function parsePagination(query: ParsedQs): CursorPagination {
  const cursor = query.cursor as string | undefined;
  const rawLimit =
    parseInt(query.limit as string) || CacheConfig.DEFAULT_PAGE_SIZE;
  return {
    cursor: cursor || undefined,
    limit: Math.min(rawLimit, CacheConfig.MAX_PAGE_SIZE),
  };
}
