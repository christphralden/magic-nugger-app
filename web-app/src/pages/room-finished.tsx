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
import { FloatingText } from "@/components/floating-text";
import { RoomLeaderboardTable } from "@/feature/room/components/room-leaderboard-table";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
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
          <div className="flex items-center justify-center">
            <Typography variant="secondary" className="text-ink-soft">
              <FloatingText text="Loading results..." duration={1} />
            </Typography>
          </div>
        ) : (
          <RoomLeaderboardTable
            rows={rows}
            currentPlayerId={currentPlayer?.id ?? ""}
          />
        )}

        <CartoonButton variant="secondary" onClick={() => navigate("/game")}>
          Back to Game
        </CartoonButton>
      </div>
    </PageLayout>
  );
}
