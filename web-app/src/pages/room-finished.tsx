import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import {
  selectRoomLeaderboard,
  clearRoomLeaderboard,
} from "@/feature/room/state/room.slice";
import { handleGetRoomLeaderboard } from "@/feature/room/state/room.actions";
import { useRoomSse } from "@/hooks/use-room-sse";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { FloatingText } from "@/components/floating-text";
import { nameInitials, cn } from "@/lib/utils";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import type {
  RoomLeaderboardRow,
  RoomWithMembers,
} from "@magic-nugger-app/shared";
import { toastInfo } from "@/lib/toast";

export function RoomFinishedPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const currentPlayer = useSelector(selectCurrentPlayer);
  const rows = useSelector(selectRoomLeaderboard);

  const [roomData, setRoomData] = useState<RoomWithMembers | null>(null);
  const [isCompleted, setIsCompleted] = useState(false);

  useEffect(() => {
    dispatch(handleGetRoomLeaderboard(id!));
    return () => {
      dispatch(clearRoomLeaderboard());
    };
  }, [id, dispatch]);

  const { register } = useRoomSse(id ?? null);

  const refreshLeaderboard = () => {
    dispatch(handleGetRoomLeaderboard(id!));
  };

  register(ROOM_SSE_EVENTS.INIT, (data) => {
    setRoomData(data);
    if (data.room.status === "completed") {
      setIsCompleted(true);
    }
  });
  register(ROOM_SSE_EVENTS.MEMBER_LEFT, (data) => {
    const member = roomData?.members.find(
      (m) => m.player_id === data.player_id,
    );
    if (member && member.player_id !== currentPlayer?.id) {
      toastInfo(`${member.display_name || member.username} has left`);
    }
    setRoomData((prev) =>
      prev
        ? {
            ...prev,
            members: prev.members.filter(
              (m) => m.player_id !== (data as { player_id: string }).player_id,
            ),
          }
        : prev,
    );
    refreshLeaderboard();
  });
  register(ROOM_SSE_EVENTS.SESSION_UPDATE, () => refreshLeaderboard());
  register(ROOM_SSE_EVENTS.ROOM_COMPLETED, () => {
    refreshLeaderboard();
    setIsCompleted(true);
  });

  return (
    <PageLayout title="Results">
      <div className="flex flex-col items-center h-full gap-6 max-w-2xl mx-auto w-full">
        <div className="flex items-center justify-between w-full">
          <Typography variant="heading">
            {isCompleted ? "Final Results" : "Results"}
          </Typography>
          {!isCompleted && (
            <Typography variant="secondary" className="text-ink-soft">
              <FloatingText text="Waiting for players..." duration={2} />
            </Typography>
          )}
        </div>

        {rows.length === 0 ? (
          <div className="flex-1 flex items-center justify-center">
            <Typography variant="secondary" className="text-ink-soft">
              <FloatingText text="Loading results..." duration={1} />
            </Typography>
          </div>
        ) : (
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
                    isMe={row.player_id === currentPlayer?.id}
                  />
                ))}
              </TableBody>
            </Table>
          </div>
        )}

        <CartoonButton variant="secondary" onClick={() => navigate("/game")}>
          Back to Game
        </CartoonButton>
      </div>
    </PageLayout>
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
          <Typography
            variant="label"
            className={isMe ? "text-coral" : undefined}
          >
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
