import type { CursorPagination } from "@magic-nugger-app/shared";

export function buildCacheKey(config: {
  table: string;
  identity: Record<string, string | number>;
  pagination: CursorPagination;
}): string {
  const identityPart = Object.entries(config.identity)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([k, v]) => `${k}=${v}`)
    .join(":");
  const { cursor, limit } = config.pagination;
  return `${config.table}:${identityPart}:cursor=${cursor ?? ""}:limit=${limit}`;
}

export function buildInvalidationPrefix(config: {
  table: string;
  identity: Record<string, string | number>;
}): string {
  const identityPart = Object.entries(config.identity)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([k, v]) => `${k}=${v}`)
    .join(":");
  return `${config.table}:${identityPart}:`;
}
