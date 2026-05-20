import { Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Typography } from "@/components/ui/typography";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { LevelRow } from "./level-row";
import { EmptyRow } from "./empty-row";
import type { LevelLeaderboardRow } from "@magic-nugger-app/shared";

interface LevelLeaderboardTableProps {
  items: LevelLeaderboardRow[];
  currentPlayerId: string;
  isLoading: boolean;
  pageOffset?: number;
  currentSessionEntry?: LevelLeaderboardRow;
}

export function LevelLeaderboardTable({
  items,
  currentPlayerId,
  isLoading,
  pageOffset = 0,
  currentSessionEntry,
}: LevelLeaderboardTableProps) {
  const playerInItems = currentSessionEntry
    ? items.some((row) => row.player_id === currentPlayerId)
    : false;

  return (
    <ScrollArea className="h-[480px]">
      <Table>
        <TableHeader>
          <TableRow header>
            <TableHead colSpan={1}>
              <Typography variant="label" className="text-ink-soft">
                #
              </Typography>
            </TableHead>
            <TableHead colSpan={3} className="w-full">
              <Typography variant="label" className="text-ink-soft">
                Player
              </Typography>
            </TableHead>
            <TableHead className="text-right min-w-[10rem]" colSpan={1}>
              <Typography variant="label" className="text-ink-soft">
                Best Score
              </Typography>
            </TableHead>
            <TableHead className="text-right min-w-[10rem]" colSpan={1}>
              <Typography variant="label" className="text-ink-soft">
                Best Streak
              </Typography>
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody className={cn(isLoading && "opacity-50")}>
          {items.map((row, i) => (
            <LevelRow
              key={row.player_id}
              row={row}
              rank={pageOffset + i + 1}
              currentPlayerId={currentPlayerId}
              overrideName={
                playerInItems && row.player_id === currentPlayerId
                  ? "Me (best)"
                  : undefined
              }
            />
          ))}
          {currentSessionEntry && (
            <>
              {!playerInItems && (
                <TableRow>
                  <TableCell colSpan={6} className="py-1 text-center">
                    <Typography variant="caption" className="text-ink-soft">
                      &middot;&middot;&middot;
                    </Typography>
                  </TableCell>
                </TableRow>
              )}
              <LevelRow
                row={currentSessionEntry}
                rank={items.length + 1}
                currentPlayerId={currentPlayerId}
                overrideName="Me (current)"
              />
            </>
          )}
          {!isLoading && items.length === 0 && !currentSessionEntry && (
            <EmptyRow colSpan={6} message="No scores yet." />
          )}
        </TableBody>
        {isLoading && (
          <TableRow>
            <TableCell colSpan={6}>
              <Loader2 className="animate-spin mx-auto" />
            </TableCell>
          </TableRow>
        )}
      </Table>
    </ScrollArea>
  );
}
