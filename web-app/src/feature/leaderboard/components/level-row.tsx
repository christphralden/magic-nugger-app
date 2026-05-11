import { TableRow, TableCell } from "@/components/ui/table";
import { Typography } from "@/components/ui/typography";
import { cn } from "@/lib/utils";
import type { LevelLeaderboardRow } from "@magic-nugger-app/shared";

interface LevelRowProps {
  row: LevelLeaderboardRow;
  rank: number;
  currentPlayerId: string;
}

export function LevelRow({ row, rank, currentPlayerId }: LevelRowProps) {
  const isMe = row.player_id === currentPlayerId;
  const name = isMe ? "Me" : row.display_name || row.username;
  return (
    <TableRow>
      <TableCell className="w-16">
        <Typography
          variant="label"
          className={cn(
            "text-ink-soft",
            rank === 1 && "text-gold",
            rank === 2 && "text-ink/40",
            rank === 3 && "text-lavender",
          )}
        >
          {rank}
        </Typography>
      </TableCell>
      <TableCell>
        <Typography variant="label" className={isMe ? "text-coral" : undefined}>
          {name}
        </Typography>
      </TableCell>
      <TableCell className="text-right">
        <Typography variant="label" className="text-coral">
          {row.best_score}
        </Typography>
      </TableCell>
      <TableCell className="text-right">
        <Typography variant="label">{row.max_streak}</Typography>
      </TableCell>
    </TableRow>
  );
}
