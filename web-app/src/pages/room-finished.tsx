import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useDispatch, useSelector } from "@/store/hooks";
import {
  selectRoomLeaderboard,
  clearRoomLeaderboard,
  updateLeaderboardRow,
} from "@/feature/room/state/room.slice";
import { handleGetRoomLeaderboard } from "@/feature/room/state/room.actions";
import { useRoomSse } from "@/hooks/use-room-sse";
import { useRoom } from "@/contexts/room.context";
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
import type { RoomLeaderboardRow } from "@magic-nugger-app/shared";
import { toastError, toastInfo } from "@/lib/toast";

export function RoomFinishedPage() {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const { roomId, roomData, setRoomData, currentPlayer, onSseError } =
    useRoom();
  const rows = useSelector(selectRoomLeaderboard);

  const [isCompleted, setIsCompleted] = useState(false);

  useEffect(() => {
    dispatch(handleGetRoomLeaderboard(roomId));
    return () => {
      dispatch(clearRoomLeaderboard());
    };
  }, [roomId, dispatch]);

  const refreshLeaderboard = () => dispatch(handleGetRoomLeaderboard(roomId));

  useRoomSse(
    roomId,
    {
      [ROOM_SSE_EVENTS.INIT]: (data) => {
        switch (data.room.status) {
          case "creation":
            toastError("Room is still being set up");
            navigate(`..`);
            break;
          case "waiting":
            toastError("Game has not yet started");
            navigate(`/game/room/${roomId}`);
            break;
          case "in_progress":
            break;
          case "completed":
            setIsCompleted(true);
            break;
          case "cancelled":
            toastError("Room ceased to exist");
            navigate("..");
            break;
        }
      },
      [ROOM_SSE_EVENTS.SESSION_STARTED]: (data) => {
        dispatch(
          updateLeaderboardRow({
            player_id: data.player_id,
            session_status: "in_progress",
          }),
        );
      },
      [ROOM_SSE_EVENTS.ANSWER_UPDATE]: (data) => {
        dispatch(
          updateLeaderboardRow({
            player_id: data.player_id,
            score: data.score,
            correct_count: data.correct_count,
            incorrect_count: data.incorrect_count,
          }),
        );
      },
      [ROOM_SSE_EVENTS.SESSION_UPDATE]: (data) => {
        if (data.session_status === "completed") setIsCompleted(true);
        dispatch(
          updateLeaderboardRow({
            player_id: data.player_id,
            session_status: data.session_status,
            score: data.score,
            elo_delta: data.elo_delta,
            correct_count: data.correct_count,
            incorrect_count: data.incorrect_count,
            max_streak: data.max_streak,
          }),
        );
        refreshLeaderboard();
      },
      [ROOM_SSE_EVENTS.MEMBER_LEFT]: (data) => {
        const isMe = data.player_id === currentPlayer?.id;
        const member = roomData?.members.find(
          (m) => m.player_id === data.player_id,
        );
        setRoomData((prev) => {
          if (!prev) return prev;
          return {
            ...prev,
            members: prev.members.filter((m) => m.player_id !== data.player_id),
          };
        });
        if (isMe) {
          toastInfo("You have left the room");
          navigate("/game");
        } else if (member) {
          toastInfo(`${member.display_name || member.username} has left`);
        }
        refreshLeaderboard();
      },
      [ROOM_SSE_EVENTS.ROOM_COMPLETED]: () => {
        setIsCompleted(true);
        refreshLeaderboard();
      },
    },
    { onError: onSseError },
  );

  return (
    <PageLayout title="Results">
      <div className="flex flex-col items-center h-full gap-6 max-w-2xl mx-auto w-full">
        <div className="flex items-center justify-between w-full">
          <Typography variant="heading" className="mx-auto">
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
