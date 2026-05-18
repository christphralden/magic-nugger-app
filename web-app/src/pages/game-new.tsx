import { useEffect, useRef, useState } from "react";
import { FloatingText } from "@/components/floating-text";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
import { ConfirmLeaveDialog } from "@/components/ui/confirm-leave-dialog";
import { useUnityBridge } from "@/hooks/use-unity-bridge";
import { useDispatch, useSelector } from "@/store/hooks";
import {
  selectLevelsStatus,
  selectUnlockedLevelsStatus,
} from "@/feature/levels/state/levels.slice";
import {
  handleGetLevels,
  handleGetUnlockedLevels,
} from "@/feature/levels/state/levels.actions";
import { Unity } from "react-unity-webgl";

import { useNavigate, useParams, useBlocker } from "react-router-dom";
import { useRoomSse } from "@/hooks/use-room-sse";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import type { Question, RoomWithMembers } from "@magic-nugger-app/shared";
import { toastError, toastInfo } from "@/lib/toast";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";

function GameView() {
  const { provider, isLoaded } = useUnityBridge();

  return (
    <PageLayout title="Game">
      {!isLoaded && (
        <div className="absolute w-full h-full flex justify-center items-center">
          <Typography variant={"heading"}>
            <FloatingText text="Loading your nuggers..." duration={1} />
          </Typography>
        </div>
      )}
      <div className="flex justify-center w-full h-full items-center">
        <Unity unityProvider={provider} className="w-full h-full" />
      </div>
    </PageLayout>
  );
}

export function RoomGameView({ roomId }: { roomId: string }) {
  const navigate = useNavigate();
  const allowNavRef = useRef(false);
  const gameActiveRef = useRef(false);

  const [roomData, setRoomData] = useState<RoomWithMembers | null>(null);
  const questions = roomData?.room.questions?.data;
  const currentPlayer = useSelector(selectCurrentPlayer);
  const isHost = currentPlayer?.id === roomData?.room.host_id;

  const { provider, isLoaded } = useUnityBridge({
    roomId,
    questions: questions,
    onSessionFinished: () => {
      allowNavRef.current = true;
      navigate(`/game/room/${roomId}/finished`);
    },
  });

  useRoomSse(
    roomId,
    {
      [ROOM_SSE_EVENTS.INIT]: (data) => {
        if (data.room.status !== "in_progress") {
          toastError("Game has not yet started");
          allowNavRef.current = true;
          navigate(`/game/room/${roomId}`);
        } else {
          gameActiveRef.current = true;
          setRoomData(data);
        }
      },
      [ROOM_SSE_EVENTS.ROOM_CANCELLED]: () => {
        allowNavRef.current = true;
        toastInfo(
          isHost
            ? "The room has been destroyed"
            : "The room has been destroyed by the host",
        );
        navigate("/game/room/new");
      },
    },
    {
      onError: (status) => {
        toastError(
          status === 403 ? "No access to this room" : "Room connection failed",
        );
        allowNavRef.current = true;
        navigate("/game/room/new");
      },
    },
  );

  const blocker = useBlocker(({ currentLocation, nextLocation }) => {
    if (allowNavRef.current) return false;
    if (currentLocation.pathname === nextLocation.pathname) return false;
    return gameActiveRef.current;
  });

  useEffect(() => {
    if (!gameActiveRef.current) return;
    const handleBeforeUnload = () => {
      fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/leave`, {
        method: "DELETE",
        credentials: "include",
        keepalive: true,
      });
    };
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [roomId]);

  return (
    <PageLayout title="Game">
      {blocker.state === "blocked" && (
        <ConfirmLeaveDialog
          title="Abandon game?"
          description="Your session will be marked as abandoned and affect your ELO."
          onConfirm={() => {
            allowNavRef.current = true;
            fetch(
              `${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/leave`,
              {
                method: "DELETE",
                credentials: "include",
                keepalive: true,
              },
            );
            blocker.proceed?.();
          }}
          onCancel={() => blocker.reset?.()}
        />
      )}

      {!isLoaded && (
        <div className="absolute w-full h-full flex justify-center items-center">
          <Typography variant="heading">
            <FloatingText text="Loading your nuggers..." duration={1} />
          </Typography>
        </div>
      )}
      <div className="flex justify-center w-full h-full items-center">
        <Unity unityProvider={provider} className="w-full h-full" />
      </div>
    </PageLayout>
  );
}

export function NewGamePage() {
  const { id } = useParams<{ id: string | undefined }>();
  const dispatch = useDispatch();
  const levelsStatus = useSelector(selectLevelsStatus);
  const unlockedStatus = useSelector(selectUnlockedLevelsStatus);

  useEffect(() => {
    dispatch(handleGetLevels());
    dispatch(handleGetUnlockedLevels());
  }, [dispatch]);

  const ready = levelsStatus === "succeeded" && unlockedStatus === "succeeded";

  if (!ready) {
    return (
      <PageLayout title="Game">
        <div className="w-full h-full flex justify-center items-center">
          <Typography variant={"heading"}>
            <FloatingText text="Loading your nuggers..." duration={1} />
          </Typography>
        </div>
      </PageLayout>
    );
  }

  if (id) {
    return <RoomGameView roomId={id} />;
  }

  return <GameView />;
}
