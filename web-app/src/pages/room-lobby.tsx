import { useState, useEffect, useRef, useMemo, useCallback } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import {
  handleStartRoom,
  handleCancelRoom,
} from "@/feature/room/state/room.actions";
import { leaveRoom } from "@/feature/room/state/room.thunk";
import { useRoomSse } from "@/hooks/use-room-sse";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { Timer } from "@/components/ui/timer";
import { PlayerTile, EmptySlot } from "@/feature/room/components/player-tile";
import { FloatingText } from "@/components/floating-text";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { ROOM_WAITING_TTL_MS } from "@/constants";
import type {
  RoomWithMembers,
  RoomMemberDetail,
} from "@magic-nugger-app/shared";
import { Copy, Check } from "lucide-react";
import { toastError, toastInfo } from "@/lib/toast";
import { CartoonPill } from "@/components/ui/cartoon-pill";
import { Button } from "@/components/ui/button";

export function RoomLobbyPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const { register } = useRoomSse(id ?? null);

  const currentPlayer = useSelector(selectCurrentPlayer);

  const [roomData, setRoomData] = useState<RoomWithMembers | null>(null);
  const [copied, setCopied] = useState(false);
  const [starting, setStarting] = useState(false);

  const isHost = currentPlayer?.id === roomData?.room.host_id;
  const gameStartedRef = useRef(false);
  const isHostRef = useRef(isHost);

  register(ROOM_SSE_EVENTS.INIT, (data) => setRoomData(data));
  register(ROOM_SSE_EVENTS.MEMBER_JOINED, (data) => {
    setRoomData((prev) => {
      if (!prev) {
        return prev;
      }
      if (prev.members.some((m) => m.player_id === data.player_id)) return prev;
      return {
        ...prev,
        members: [...prev.members, data as RoomMemberDetail],
      };
    });
    if (data.player_id !== currentPlayer?.id) {
      toastInfo(`${data.display_name || data.username} has joined`);
    }
  });
  register(ROOM_SSE_EVENTS.MEMBER_LEFT, (data) => {
    const member = members.find((m) => m.player_id === data.player_id);
    if (member && member.player_id !== currentPlayer?.id) {
      toastInfo(`${member.display_name || member.username} has left`);
    } else {
      toastInfo("You have left the room");
      navigate("/game");
    }
    setRoomData((prev) =>
      prev
        ? {
            ...prev,
            members: prev.members.filter((m) => m.player_id !== data.player_id),
          }
        : prev,
    );
  });
  register(ROOM_SSE_EVENTS.ROOM_STARTED, () => {
    gameStartedRef.current = true;
    navigate(`/game/room/${id}/play`);
  });
  register(ROOM_SSE_EVENTS.ROOM_CANCELLED, () => {
    if (isHost) {
      toastError("The room has been destroyed");
    } else {
      toastError("The room has been destroyed by the host");
    }

    navigate("/game/room/new");
  });

  const handleCopy = async () => {
    if (!roomData?.room.invite_code) return;
    await navigator.clipboard.writeText(roomData.room.invite_code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleStart = async () => {
    if (!id) return;
    setStarting(true);
    await dispatch(handleStartRoom(id));
    setStarting(false);
  };

  const timerEnd: number | null = useMemo(() => {
    if (!roomData?.room.created_at) return null;
    return new Date(roomData.room.created_at).getTime() + ROOM_WAITING_TTL_MS;
  }, [roomData?.room.created_at]);

  const handleTimerEnd = useCallback(() => {
    if (isHostRef.current && id) dispatch(handleCancelRoom(id));
    toastError("Room is closed due to inactivity, create a new room");
    navigate("/game/room/new");
    return;
  }, []);

  const handleDestroyRoom = () => {
    if (id) {
      dispatch(handleCancelRoom(id));
    }
  };
  const handleLeaveRoom = () => {
    if (id) {
      dispatch(leaveRoom(id));
    }
  };
  useEffect(() => {
    return () => {
      // if (gameStartedRef.current || !roomIdRef.current) return;
      // if (isHostRef.current) ;
      // else dispatch(leaveRoom(roomIdRef.current));
    };
  }, []);

  if (!roomData) {
    return (
      <PageLayout title="Lobby">
        <div className="w-full h-full flex justify-center items-center">
          <Typography variant="heading">
            <FloatingText text="Joining room..." duration={1} />
          </Typography>
        </div>
      </PageLayout>
    );
  }

  const { room, members } = roomData;
  const emptySlots = Math.max(0, room.max_players - members.length);

  return (
    <PageLayout title="Lobby">
      <div className="flex flex-col items-center gap-6 relative z-[1] py-4">
        <CartoonPill className="bg-gold hover:animate-nudge">
          Waiting room
        </CartoonPill>
        <div className="flex flex-col items-center gap-2 text-center gap-4">
          <Typography variant="heading">
            <FloatingText
              text={
                isHost ? "Gather your crew" : "Waiting for host to start..."
              }
              duration={2}
            />
          </Typography>
          <Typography variant="secondary" className="text-ink-soft">
            Share the invite code. Game starts when the host hits play.
          </Typography>
        </div>

        <div className="bg-paper border-[3px] border-border rounded-2xl shadow-cartoon-lg p-7 w-full max-w-3xl flex flex-col gap-6">
          <div className="flex items-start justify-between gap-5 flex-wrap">
            <div className="flex flex-col gap-2 flex-1 min-w-[280px]">
              <div className="flex items-center justify-between">
                <Typography variant="secondary" as="span">
                  Invite code
                </Typography>
                <Timer end={timerEnd} onEnd={handleTimerEnd} />
              </div>
              <Button
                onClick={handleCopy}
                className="flex items-center justify-between gap-3 bg-cream border-[3px] border-border rounded-xl px-4 py-8 hover:bg-cream hover:brightness-95 transition-all cursor-pointer shadow-cartoon-sm"
              >
                <Typography variant="primary" className="tracking-[0.25em]">
                  {room.invite_code}
                </Typography>
                <div className="bg-white border-[2.5px] border-ink rounded-xl p-2 shadow-cartoon-sm shrink-0">
                  {copied ? (
                    <Check className="size-4 text-teal-deep" />
                  ) : (
                    <Copy className="size-4 text-ink" />
                  )}
                </div>
              </Button>
              <Typography variant="label" className="text-ink-soft">
                Share this code with friends to join
              </Typography>
            </div>
          </div>

          <div className="flex flex-col gap-4">
            <div className="flex items-baseline justify-between">
              <Typography variant="secondary">Players</Typography>
              <Typography variant="secondary" as="span">
                <span className="text-coral">{members.length}</span>
                {" / "}
                {room.max_players}
              </Typography>
            </div>

            <div className="grid grid-cols-3 sm:grid-cols-5 gap-3">
              {members.map((member) => (
                <PlayerTile
                  key={member.player_id}
                  member={member}
                  isHost={member.player_id === room.host_id}
                  isMe={member.player_id === currentPlayer?.id}
                />
              ))}
              {Array.from({ length: emptySlots }).map((_, i) => (
                <EmptySlot key={i} idx={members.length + i + 1} />
              ))}
            </div>
          </div>

          <div className="flex gap-4">
            {isHost && (
              <CartoonButton
                variant={"secondary"}
                onClick={handleDestroyRoom}
                disabled={starting}
                size="lg"
                className="w-full"
              >
                Destroy room
              </CartoonButton>
            )}
            {isHost && (
              <CartoonButton
                onClick={handleStart}
                disabled={starting || members.length < 2}
                size="lg"
                className="w-full"
              >
                {starting ? "Starting..." : "Start game"}
              </CartoonButton>
            )}

            {!isHost && (
              <CartoonButton
                onClick={handleLeaveRoom}
                disabled={starting || members.length < 2}
                size="lg"
                className="w-full"
              >
                Leave room
              </CartoonButton>
            )}
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
