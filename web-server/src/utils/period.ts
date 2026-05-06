import type { ParsedQs } from "qs";
import type { LeaderboardPeriod } from "@magic-nugger-app/shared";

export function parsePeriod(query: ParsedQs): LeaderboardPeriod {
  const p = query.period as string;
  if (p === "week" || p === "month") return p;
  return "alltime";
}

export function periodToStartDate(period: LeaderboardPeriod): string | null {
  if (period === "week") return new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  if (period === "month") return new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
  return null;
}
