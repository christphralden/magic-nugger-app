import { useEffect, useRef } from "react";
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
import { useRoom } from "@/contexts/room.context";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { toastError } from "@/lib/toast";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";

function GameView() {
  const { provider, isLoaded } = useUnityBridge();

  return (
    <PageLayout title="Game" headless>
      {!isLoaded && (
        <div className="absolute w-full h-full flex justify-center items-center top-0 left-0">
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

export function RoomGameView() {
  const navigate = useNavigate();
  const allowNavRef = useRef(false);
  const gameActiveRef = useRef(false);

  const { roomId, roomData, setRoomData, handleRoomCancelled, onSseError } =
    useRoom();
  const questions = roomData?.room.questions?.data;

  const { provider, isLoaded } = useUnityBridge({
    roomId,
    questions,
    onSessionFinished: () => {
      allowNavRef.current = true;
      navigate(`/game/room/${roomId}/finished`);
    },
  });

  useRoomSse(
    roomId,
    {
      [ROOM_SSE_EVENTS.INIT]: (data) => {
        switch (data.room.status) {
          case "creation":
            allowNavRef.current = true;
            toastError("Room is still being set up");
            navigate(`..`);
            break;
          case "waiting":
            allowNavRef.current = true;
            toastError("Room has not yet started");
            navigate(`/game/room/${roomId}`);
            break;
          case "in_progress":
            gameActiveRef.current = true;
            setRoomData(data);
            break;
          case "completed":
            allowNavRef.current = true;
            toastError("Game has already completed");
            navigate(`/game/room/${roomId}/finished`);
            break;
          case "cancelled":
            allowNavRef.current = true;
            toastError("Game ceased to exist");
            navigate("..");
            break;
        }
      },
      [ROOM_SSE_EVENTS.ROOM_CANCELLED]: () => {
        allowNavRef.current = true;
        handleRoomCancelled();
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
    if (currentLocation.pathname === nextLocation.pathname) return false;
    return gameActiveRef.current;
  });

  useEffect(() => {
    const handleBeforeUnload = () => {
      if (!gameActiveRef.current) return;
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

export function GamePlayPage() {
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
    return <RoomGameView />;
  }

  return <GameView />;
}
