import { cn } from "@/lib/utils";
import { nameInitials } from "@/lib/utils";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Typography } from "@/components/ui/typography";
import { FloatingText } from "@/components/floating-text";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import type { RoomLeaderboardRow } from "@magic-nugger-app/shared";

interface RoomLeaderboardTableProps {
  rows: RoomLeaderboardRow[];
  currentPlayerId: string;
}

export function RoomLeaderboardTable({ rows, currentPlayerId }: RoomLeaderboardTableProps) {
  return (
    <div className="w-full bg-paper border-[3px] border-border rounded-2xl shadow-cartoon overflow-hidden">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-12">#</TableHead>
            <TableHead>Player</TableHead>
            <TableHead className="text-right">Score</TableHead>
            <TableHead className="text-right">ELO</TableHead>
            <TableHead className="text-right">Correct</TableHead>
            <TableHead className="text-right">Status</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {rows.map((row, index) => (
            <ResultRow
              key={row.player_id}
              row={row}
              rank={index + 1}
              isMe={row.player_id === currentPlayerId}
            />
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

function ResultRow({
  row,
  rank,
  isMe,
}: {
  row: RoomLeaderboardRow;
  rank: number;
  isMe: boolean;
}) {
  const name = isMe ? "Me" : row.display_name || row.username;
  const isPlaying = row.session_status === "in_progress";
  const notStarted = row.session_status === null;

  return (
    <TableRow>
      <TableCell>
        <Typography
          variant="label"
          className={cn(
            "text-ink-soft",
            rank === 1 && "text-gold",
            rank === 2 && "text-ink/40",
            rank === 3 && "text-lavender",
          )}
        >
          {notStarted || isPlaying ? "—" : rank}
        </Typography>
      </TableCell>
      <TableCell>
        <div className="flex items-center gap-3">
          <Avatar className="size-8">
            {row.avatar_url && <AvatarImage src={row.avatar_url} />}
            <AvatarFallback>
              {nameInitials(row.display_name || row.username)}
            </AvatarFallback>
          </Avatar>
          <Typography variant="label" className={isMe ? "text-coral" : undefined}>
            {name}
          </Typography>
        </div>
      </TableCell>
      <TableCell className="text-right">
        <Typography variant="label">{row.score ?? "—"}</Typography>
      </TableCell>
      <TableCell className="text-right">
        <Typography
          variant="label"
          className={cn(
            row.elo_delta != null && row.elo_delta > 0 && "text-green-600",
            row.elo_delta != null && row.elo_delta < 0 && "text-red-500",
          )}
        >
          {row.elo_delta != null
            ? row.elo_delta > 0
              ? `+${row.elo_delta}`
              : `${row.elo_delta}`
            : "—"}
        </Typography>
      </TableCell>
      <TableCell className="text-right">
        <Typography variant="label">
          {row.correct_count != null
            ? `${row.correct_count}/${(row.correct_count ?? 0) + (row.incorrect_count ?? 0)}`
            : "—"}
        </Typography>
      </TableCell>
      <TableCell className="text-right">
        <StatusBadge status={row.session_status} />
      </TableCell>
    </TableRow>
  );
}

function StatusBadge({ status }: { status: string | null }) {
  if (!status)
    return (
      <Typography variant="caption" className="text-ink-soft">
        Not started
      </Typography>
    );
  const map: Record<string, { label: string; className: string }> = {
    completed: { label: "Done", className: "text-green-600" },
    failed: { label: "Failed", className: "text-red-500" },
    abandoned: { label: "Left", className: "text-ink-soft" },
    in_progress: { label: "Playing", className: "text-coral" },
  };
  const config = map[status] ?? { label: status, className: "text-ink-soft" };
  return (
    <Typography variant="caption" className={config.className}>
      {status === "in_progress" ? (
        <FloatingText text={config.label} duration={1.5} />
      ) : (
        config.label
      )}
    </Typography>
  );
}
