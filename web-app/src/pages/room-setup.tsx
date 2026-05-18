import { useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { handleSaveRoomQuestions } from "@/feature/room/state/room.actions";
import { useRoomSse } from "@/hooks/use-room-sse";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
import { FloatingText } from "@/components/floating-text";
import { CartoonPill } from "@/components/ui/cartoon-pill";
import { QuestionsForm } from "@/feature/room/components/questions-form";
import type { QuestionsFormValues } from "@/feature/room/components/questions-form";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { toastError, toastInfo } from "@/lib/toast";
import type { RoomWithMembers } from "@magic-nugger-app/shared";

export function RoomSetupPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const currentPlayer = useSelector(selectCurrentPlayer);

  const [roomData, setRoomData] = useState<RoomWithMembers | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const isHost = currentPlayer?.id === roomData?.room.host_id;

  useRoomSse(
    id ?? null,
    {
      [ROOM_SSE_EVENTS.INIT]: (data) => {
        if (data.room.status !== "creation") {
          navigate(`/game/room/${id}`);
          return;
        }
        if (data.room.host_id !== currentPlayer?.id) {
          toastError("Only the host can set up questions");
          navigate(`/game/room/new`);
          return;
        }
        setRoomData(data);
      },
      [ROOM_SSE_EVENTS.ROOM_CANCELLED]: () => {
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
        navigate("/game/room/new");
      },
    },
  );

  const handleSubmit = async (values: QuestionsFormValues) => {
    if (!id) return;
    setSubmitting(true);
    const room = await dispatch(handleSaveRoomQuestions(id, values.questions));
    setSubmitting(false);
    if (room) navigate(`/game/room/${id}`);
  };

  if (!roomData) {
    return (
      <PageLayout title="Setup">
        <div className="w-full h-full flex justify-center items-center">
          <Typography variant="heading">
            <FloatingText text="Setting up room..." duration={1} />
          </Typography>
        </div>
      </PageLayout>
    );
  }

  return (
    <PageLayout title="Setup">
      <div className="flex flex-col items-center gap-6 relative z-[1] py-4">
        <CartoonPill className="bg-gold hover:animate-nudge">
          Custom questions
        </CartoonPill>
        <div className="flex flex-col items-center gap-2 text-center">
          <Typography variant="heading">
            <FloatingText text="Build your quiz" duration={2} />
          </Typography>
          <Typography variant="secondary" className="text-ink-soft">
            Add problems and mark the correct answer for each.
          </Typography>
        </div>

        <div className="w-full max-w-2xl">
          <QuestionsForm onSubmit={handleSubmit} submitting={submitting} />
        </div>
      </div>
    </PageLayout>
  );
}
