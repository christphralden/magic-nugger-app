import { useState, useEffect, useRef } from "react";
import { useNavigate, useBlocker } from "react-router-dom";
import { useDispatch } from "@/store/hooks";
import {
  handleStartRoom,
  handleCancelRoom,
  handleCloseRoom,
} from "@/feature/room/state/room.actions";
import { leaveRoom } from "@/feature/room/state/room.thunk";
import { useRoomSse } from "@/hooks/use-room-sse";
import { useRoom } from "@/contexts/room.context";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { ConfirmLeaveDialog } from "@/components/ui/confirm-leave-dialog";
import { PlayerTile, EmptySlot } from "@/feature/room/components/player-tile";
import { FloatingText } from "@/components/floating-text";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type { RoomMemberDetail } from "@magic-nugger-app/shared";
import { Copy, Check, ArrowLeft } from "lucide-react";
import { toastError, toastInfo } from "@/lib/toast";
import { CartoonPill } from "@/components/ui/cartoon-pill";
import { Button } from "@/components/ui/button";

export function RoomLobbyPage() {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const {
    roomId,
    roomData,
    setRoomData,
    isHost,
    currentPlayer,
    handleRoomCancelled,
    onSseError,
  } = useRoom();

  const [copied, setCopied] = useState(false);
  const [starting, setStarting] = useState(false);

  const allowNavRef = useRef(false);

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
            setRoomData(data);
            break;
          case "in_progress":
            toastError("Game has already started");
            navigate(`/game/room/${roomId}/finished`);
            break;
          case "completed":
            toastError("Game has already completed");
            navigate(`/game/room/${roomId}/finished`);
            break;
          case "cancelled":
            toastError("Room ceased to exist");
            navigate("..");
            break;
        }
      },
      [ROOM_SSE_EVENTS.MEMBER_JOINED]: (data) => {
        setRoomData((prev) => {
          if (!prev) return prev;
          if (prev.members.some((m) => m.player_id === data.player_id))
            return prev;
          return {
            ...prev,
            members: [...prev.members, data as RoomMemberDetail],
          };
        });
        if (data.player_id !== currentPlayer?.id) {
          toastInfo(`${data.display_name || data.username} has joined`);
        }
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
          allowNavRef.current = true;
          navigate("/game");
        } else if (member) {
          toastInfo(`${member.display_name || member.username} has left`);
        }
      },
      [ROOM_SSE_EVENTS.ROOM_STARTED]: () => {
        allowNavRef.current = true;
        navigate(
          isHost
            ? `/game/room/${roomId}/finished`
            : `/game/room/${roomId}/play`,
        );
      },
      [ROOM_SSE_EVENTS.ROOM_CANCELLED]: () => {
        allowNavRef.current = true;
        handleRoomCancelled();
      },
      [ROOM_SSE_EVENTS.ROOM_CLOSED]: () => {
        allowNavRef.current = true;
        if (isHost) {
          navigate(`/game/room/${roomId}/setup`);
        } else {
          toastInfo("Host is editing questions");
          navigate("/game/room");
        }
      },
    },
    {
      onError: (status) => {
        allowNavRef.current = true;
        onSseError(status);
      },
    },
  );

  const blocker = useBlocker(({ currentLocation, nextLocation }) => {
    if (allowNavRef.current) return false;
    if (isHost) return false;
    if (currentLocation.pathname === nextLocation.pathname) return false;
    return roomData !== null;
  });

  useEffect(() => {
    const handleBeforeUnload = () => {
      if (!roomData) return;
      if (isHost) return;
      fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/leave`, {
        method: "DELETE",
        credentials: "include",
        keepalive: true,
      });
    };
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [roomId, roomData, isHost]);

  const handleCopy = async () => {
    if (!roomData?.room.invite_code) return;
    await navigator.clipboard.writeText(roomData.room.invite_code);
    toastInfo("Invite code copied");
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleStart = async () => {
    if (members.length < 2) {
      toastError("Invite friends first before starting the game");
      return;
    }
    setStarting(true);
    await dispatch(handleStartRoom(roomId));
    setStarting(false);
  };

  const handleDestroyRoom = () => dispatch(handleCancelRoom(roomId));

  const handleLeaveRoom = () => dispatch(leaveRoom(roomId));

  const handleEditQuestions = () => dispatch(handleCloseRoom(roomId));

  const handleConfirmLeave = async () => {
    allowNavRef.current = true;
    handleLeaveRoom();
    blocker.proceed?.();
  };

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
      {blocker.state === "blocked" && (
        <ConfirmLeaveDialog
          title="Leave room?"
          description="You will be removed from the lobby."
          onConfirm={handleConfirmLeave}
          onCancel={() => blocker.reset?.()}
        />
      )}

      <div className="flex flex-col items-center relative z-[1]">
        <Button
          variant="ghost"
          onClick={() => navigate("/game/room/host")}
          className="self-start"
        >
          <ArrowLeft className="size-4 stroke-[3px]" />
          <Typography variant="label">Back</Typography>
        </Button>
        <div className="flex flex-col items-center gap-6 max-w-6xl w-full h-full">
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
            <Typography variant="secondary">
              Share the invite code! Game starts when the host hits play
            </Typography>
          </div>

          <div className="bg-paper border-[3px] border-border rounded-2xl shadow-cartoon-lg p-7 w-full max-w-3xl flex flex-col gap-6">
            <div className="flex items-start justify-between gap-5 flex-wrap">
              <div className="flex flex-col gap-2 flex-1 min-w-[280px]">
                <Typography variant="secondary" as="span">
                  Invite code
                </Typography>
                <CartoonButton
                  onClick={handleCopy}
                  size="lg"
                  variant="select"
                  className="flex items-center justify-between"
                >
                  <Typography variant="primary" className="tracking-[0.25em]">
                    {room.invite_code}
                  </Typography>
                  <div className="bg-white border-[2.5px] border-ink rounded-xl p-2 shadow-cartoon-sm shrink-0">
                    {copied ? (
                      <Check className="size-4 text-ink stroke-[4px]" />
                    ) : (
                      <Copy className="size-4 text-ink stroke-[3px] " />
                    )}
                  </div>
                </CartoonButton>
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

              <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-5 gap-3">
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
                  variant="secondary"
                  size="sm"
                  onClick={handleDestroyRoom}
                  disabled={starting}
                  className="w-full"
                >
                  Destroy room
                </CartoonButton>
              )}
              {isHost && (
                <CartoonButton
                  variant="secondary"
                  size="sm"
                  onClick={handleEditQuestions}
                  disabled={starting}
                  className="w-full"
                >
                  Edit questions
                </CartoonButton>
              )}
              {isHost && (
                <CartoonButton
                  size="sm"
                  onClick={handleStart}
                  disabled={starting}
                  className="w-full"
                >
                  {starting ? "Starting..." : "Start game"}
                </CartoonButton>
              )}

              {!isHost && (
                <CartoonButton
                  onClick={handleLeaveRoom}
                  disabled={starting}
                  className="w-full"
                  size="sm"
                >
                  Leave room
                </CartoonButton>
              )}
            </div>
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
