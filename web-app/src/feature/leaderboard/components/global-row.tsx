import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Typography } from "@/components/ui/typography";
import { cn, nameInitials } from "@/lib/utils";
import type { GlobalLeaderboardRow } from "@magic-nugger-app/shared";

interface GlobalRowProps {
  row: GlobalLeaderboardRow;
  rank: number;
  currentPlayerId: string;
}

export function GlobalRow({ row, rank, currentPlayerId }: GlobalRowProps) {
  const isMe = row.id === currentPlayerId;
  const name = isMe ? "Me" : row.display_name || row.username;
  return (
    <tr className="border-b-[2px] border-border last:border-0 hover:bg-cream/50 transition-colors">
      <td className="px-6 py-4 w-16">
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
      </td>
      <td className="px-6 py-4">
        <div className="flex items-center gap-3">
          <Avatar className="size-8">
            {row.avatar_url && <AvatarImage src={row.avatar_url} />}
            <AvatarFallback className="text-xs">
              {nameInitials(row.display_name || row.username)}
            </AvatarFallback>
          </Avatar>
          <Typography
            variant="label"
            className={isMe ? "text-coral" : undefined}
          >
            {name}
          </Typography>
        </div>
      </td>
      <td className="px-6 py-4 text-right">
        <Typography variant="label" className="text-coral">
          {row.current_elo}
        </Typography>
      </td>
      <td className="px-6 py-4 text-right">
        <Typography variant="label">{row.max_streak}</Typography>
      </td>
    </tr>
  );
}
