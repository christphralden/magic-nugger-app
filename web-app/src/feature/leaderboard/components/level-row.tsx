import { TableRow, TableCell } from "@/components/ui/table";
import { Typography } from "@/components/ui/typography";
import { cn } from "@/lib/utils";
import type { LevelLeaderboardRow } from "@magic-nugger-app/shared";

interface LevelRowProps {
  row: LevelLeaderboardRow;
  rank: number;
  currentPlayerId: string;
  overrideName?: string;
}

export function LevelRow({ row, rank, currentPlayerId, overrideName }: LevelRowProps) {
  const isMe = row.player_id === currentPlayerId;
  const name = overrideName ?? (isMe ? "Me" : row.display_name || row.username);
  return (
    <TableRow>
      <TableCell colSpan={1}>
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
      <TableCell colSpan={3}>
        <Typography variant="label" className={isMe ? "text-coral" : undefined}>
          {name}
        </Typography>
      </TableCell>
      <TableCell className="text-right" colSpan={1}>
        <Typography variant="label" className="text-coral">
          {row.best_score}
        </Typography>
      </TableCell>
      <TableCell className="text-right" colSpan={1}>
        <Typography variant="label">{row.max_streak}</Typography>
      </TableCell>
    </TableRow>
  );
}
