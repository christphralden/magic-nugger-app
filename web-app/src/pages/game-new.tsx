import { useEffect } from "react";
import { FloatingText } from "@/components/floating-text";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
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

import { useNavigate, useParams } from "react-router-dom";
import { useRoomSse } from "@/hooks/use-room-sse";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";

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
  const { register } = useRoomSse(roomId);

  const { provider, isLoaded } = useUnityBridge({
    roomId,
    onSessionFinished: () => navigate(`/game/room/${roomId}/finished`),
  });

  register(ROOM_SSE_EVENTS.INIT, (data) => {
    if (data.room.status !== "in_progress") {
      navigate(`/game/room/${roomId}`);
    }
  });

  register(ROOM_SSE_EVENTS.ROOM_CANCELLED, () => navigate("/home"));

  return (
    <PageLayout title="Game">
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
