import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { CartoonPill } from "@/components/ui/cartoon-pill";
import { Typography } from "@/components/ui/typography";
import { nameInitials } from "@/lib/utils";
import type { RoomMemberDetail } from "@magic-nugger-app/shared";

interface PlayerTileProps {
  member: RoomMemberDetail;
  isHost: boolean;
  isMe: boolean;
}

export function PlayerTile({ member, isHost, isMe }: PlayerTileProps) {
  const name = member.display_name || member.username;
  return (
    <div className="relative bg-white border-[3px] border-border rounded-lg shadow-cartoon-sm px-2 py-6 flex flex-col items-center gap-2 text-center">
      {isHost && (
        <CartoonPill className="absolute -top-4 left-1/2 -translate-x-1/2 bg-paper px-2.5 py-0.5">
          Host
        </CartoonPill>
      )}
      <Avatar className="size-12">
        {member.avatar_url && <AvatarImage src={member.avatar_url} />}
        <AvatarFallback>{nameInitials(name)}</AvatarFallback>
      </Avatar>
      <div className="flex items-baseline gap-1">
        {!isMe ? (
          <Typography variant="label" as="p" className="text-ink-soft">
            Me
          </Typography>
        ) : (
          <Typography variant="label" as="p" className="line-clamp-1">
            {name}
          </Typography>
        )}
      </div>
    </div>
  );
}

interface EmptySlotProps {
  idx: number;
}

export function EmptySlot({ idx }: EmptySlotProps) {
  return (
    <div className="border-[3px] border-dashed border-border rounded-lg opacity-55 flex flex-col items-center justify-center gap-2 px-2 py-6 min-h-[132px]">
      <div className="size-12 rounded-full border-[3px] border-dashed border-ink-soft flex items-center justify-center">
        <Typography variant="subheading" as="span">
          +
        </Typography>
      </div>
      <Typography variant="caption">Player {idx}</Typography>
    </div>
  );
}
