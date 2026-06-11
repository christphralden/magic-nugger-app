import { useEffect, useRef, useState } from "react";
import { FloatingText } from "@/components/floating-text";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
import { ConfirmLeaveDialog } from "@/components/ui/confirm-leave-dialog";
import { SessionEndDialog } from "@/components/ui/session-end-dialog";
import { useUnityBridge } from "@/hooks/use-unity-bridge";
import { useDispatch, useSelector } from "@/store/hooks";
import {
  selectLevels,
  selectActiveLevels,
  selectUnlockedLevels,
  selectLevelsStatus,
  selectUnlockedLevelsStatus,
} from "@/feature/levels/state/levels.slice";
import {
  handleGetLevels,
  handleGetUnlockedLevels,
} from "@/feature/levels/state/levels.actions";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { Unity } from "react-unity-webgl";

import { useNavigate, useParams, useBlocker } from "react-router-dom";
import { useRoomSse } from "@/hooks/use-room-sse";
import { useRoom } from "@/contexts/room.context";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { toastError, toastSuccess } from "@/lib/toast";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import { DISABLED_CANVAS_EVENTS } from "@/constants";

type SessionResult = {
  levelId: number;
  levelName: string;
  score: number;
};

function GameView() {
  const navigate = useNavigate();
  const [sessionResult, setSessionResult] = useState<SessionResult | null>(
    null,
  );
  const levels = useSelector(selectLevels);
  const currentPlayer = useSelector(selectCurrentPlayer);

  const { provider, isLoaded } = useUnityBridge({
    onCriticalError: () => navigate("/game"),
    onSessionFinished: ({
      elo_gained,
      new_levels_unlocked,
      levelId,
      score,
    }) => {
      if (!levelId) return;
      const level = levels.find((l) => l.id === levelId);

      let delay = 0;
      const STAGGER = 800;

      if (elo_gained > 0) {
        setTimeout(() => toastSuccess(`You gained ${elo_gained} ELO`), delay);
        delay += STAGGER;
      }

      for (const unlockedLevel of new_levels_unlocked) {
        setTimeout(() => toastSuccess(`Unlocked ${unlockedLevel}`), delay);
        delay += STAGGER;
      }

      setTimeout(
        () =>
          setSessionResult({ levelId, levelName: level?.name ?? "", score }),
        delay,
      );
    },
  });

  return (
    <PageLayout title="Game" headless>
      {!isLoaded && (
        <div className="absolute w-full h-full flex justify-center items-center top-0 left-0">
          <Typography variant={"heading"}>
            <FloatingText text="Summoning your hero..." duration={1} />
          </Typography>
        </div>
      )}
      <div className="flex justify-center w-full h-full items-center">
        <Unity
          unityProvider={provider}
          className="w-full h-full"
          disabledCanvasEvents={DISABLED_CANVAS_EVENTS}
        />
      </div>
      {sessionResult && currentPlayer && (
        <SessionEndDialog
          open
          levelId={sessionResult.levelId}
          levelName={sessionResult.levelName}
          score={sessionResult.score}
          currentPlayer={currentPlayer}
          onClose={() => setSessionResult(null)}
        />
      )}
    </PageLayout>
  );
}

export function RoomGameView() {
  const navigate = useNavigate();
  const allowNavRef = useRef(false);
  const gameActiveRef = useRef(false);

  const { roomId, roomData, setRoomData, isHost, handleRoomCancelled, onSseError } =
    useRoom();
  const questions = roomData?.room.questions?.data;

  const { provider, isLoaded } = useUnityBridge({
    roomId,
    questions,
    onCriticalError: () => {
      allowNavRef.current = true;
      navigate(`/game/room/${roomId}`);
    },
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
            if (isHost) {
              allowNavRef.current = true;
              navigate(`/game/room/${roomId}/finished`);
              return;
            }
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
    <PageLayout title="Game" headless>
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
            <FloatingText text="Summoning your hero..." duration={1} />
          </Typography>
        </div>
      )}
      <div className="flex justify-center w-full h-full items-center">
        <Unity
          unityProvider={provider}
          className="w-full h-full"
          disabledCanvasEvents={DISABLED_CANVAS_EVENTS}
        />
      </div>
    </PageLayout>
  );
}

export function GamePlayPage() {
  const { id } = useParams<{ id: string | undefined }>();
  const dispatch = useDispatch();
  const levelsStatus = useSelector(selectLevelsStatus);
  const unlockedStatus = useSelector(selectUnlockedLevelsStatus);
  const activeLevels = useSelector(selectActiveLevels);
  const unlockedLevels = useSelector(selectUnlockedLevels);

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
            <FloatingText text="Summoning your hero..." duration={1} />
          </Typography>
        </div>
      </PageLayout>
    );
  }

  if (id) {
    return <RoomGameView />;
  }

  if (activeLevels.length === 0) {
    return (
      <PageLayout title="Game">
        <div className="w-full h-full flex justify-center items-center">
          <Typography variant={"primary"}>
            <FloatingText text="No levels available yet :(" duration={1} />
          </Typography>
        </div>
      </PageLayout>
    );
  }

  if (unlockedLevels.length === 0) {
    return (
      <PageLayout title="Game">
        <div className="w-full h-full flex justify-center items-center">
          <Typography variant={"primary"}>
            <FloatingText text="No levels unlocked yet :(" duration={1} />
          </Typography>
        </div>
      </PageLayout>
    );
  }

  return <GameView />;
}
