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
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { FloatingText } from "@/components/floating-text";
import { nameInitials } from "@/lib/utils";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { ROOM_WAITING_TTL_MS } from "@/constants";
import type {
  RoomWithMembers,
  RoomMemberDetail,
} from "@magic-nugger-app/shared";
import { Copy, Check } from "lucide-react";
import { Timer } from "@/components/ui/timer";
import { toastInfo } from "@/lib/toast";

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
  const roomIdRef = useRef(id);
  const gameStartedRef = useRef(false);
  const isHostRef = useRef(isHost);

  register(ROOM_SSE_EVENTS.INIT, (data) => setRoomData(data));
  register(ROOM_SSE_EVENTS.MEMBER_JOINED, (data) => {
    setRoomData((prev) =>
      prev
        ? { ...prev, members: [...prev.members, data as RoomMemberDetail] }
        : prev,
    );
    if (data.player_id !== currentPlayer?.id) {
      toastInfo(`${data.display_name || data.username} has joined`);
    }
  });
  register(ROOM_SSE_EVENTS.MEMBER_LEFT, (data) => {
    const member = members.find((m) => m.player_id === data.player_id);
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
  });
  register(ROOM_SSE_EVENTS.ROOM_STARTED, () => {
    gameStartedRef.current = true;
    navigate(`/game/room/${id}/play`);
  });
  register(ROOM_SSE_EVENTS.ROOM_CANCELLED, () => navigate("/game/room/new"));

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
    navigate("/game/room/new");
    return;
  }, []);

  useEffect(() => {
    return () => {
      if (gameStartedRef.current || !roomIdRef.current) return;
      if (isHostRef.current) dispatch(handleCancelRoom(roomIdRef.current));
      else dispatch(leaveRoom(roomIdRef.current));
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

  return (
    <PageLayout title="Lobby">
      <div className="flex flex-col items-center justify-center h-full gap-8">
        <div className="bg-paper border-[3px] border-border rounded-2xl shadow-cartoon p-8 w-full max-w-md flex flex-col gap-6">
          <div className="flex flex-col gap-1">
            <div className="flex items-center justify-between">
              <Typography variant="label">Invite Code</Typography>
              <Timer end={timerEnd} onEnd={handleTimerEnd}></Timer>
            </div>
            <button
              onClick={handleCopy}
              className="flex items-center gap-3 bg-cream border-[3px] border-border rounded-xl px-5 py-3 hover:brightness-95 transition-all cursor-pointer w-full"
            >
              <Typography
                variant="primary"
                className="tracking-[0.25em] flex-1 text-left"
              >
                {room.invite_code}
              </Typography>
              {copied ? (
                <Check className="size-5 text-green-500 shrink-0" />
              ) : (
                <Copy className="size-5 text-ink-soft shrink-0" />
              )}
            </button>
            <Typography variant="caption">
              Share this code with friends to join
            </Typography>
          </div>

          <div className="flex flex-col gap-3">
            <div className="flex items-center justify-between">
              <Typography variant="label">Players</Typography>
              <Typography variant="caption" className="text-ink-soft">
                {members.length} / {room.max_players}
              </Typography>
            </div>
            <div className="flex flex-col gap-2">
              {members.map((member) => (
                <MemberRow
                  key={member.player_id}
                  member={member}
                  isHost={member.player_id === room.host_id}
                />
              ))}
            </div>
          </div>

          {isHost ? (
            <CartoonButton
              onClick={handleStart}
              disabled={starting || members.length < 2}
            >
              {starting ? "Starting..." : "Start Game"}
            </CartoonButton>
          ) : (
            <div className="flex justify-center py-2">
              <Typography variant="secondary" className="text-ink-soft">
                <FloatingText
                  text="Waiting for host to start..."
                  duration={2}
                />
              </Typography>
            </div>
          )}
        </div>
      </div>
    </PageLayout>
  );
}

function MemberRow({
  member,
  isHost,
}: {
  member: RoomMemberDetail;
  isHost: boolean;
}) {
  const name = member.display_name || member.username;
  return (
    <div className="flex items-center gap-3 bg-cream rounded-xl px-4 py-2.5">
      <Avatar className="size-8">
        {member.avatar_url && <AvatarImage src={member.avatar_url} />}
        <AvatarFallback>{nameInitials(name)}</AvatarFallback>
      </Avatar>
      <Typography variant="label" className="flex-1">
        {name}
      </Typography>
      {isHost && (
        <Typography variant="caption" className="text-coral">
          Host
        </Typography>
      )}
    </div>
  );
}
