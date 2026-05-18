import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useDispatch } from "@/store/hooks";
import { handleSaveRoomQuestions } from "@/feature/room/state/room.actions";
import { useRoomSse } from "@/hooks/use-room-sse";
import { useRoom } from "@/contexts/room.context";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
import { FloatingText } from "@/components/floating-text";
import { CartoonPill } from "@/components/ui/cartoon-pill";
import { QuestionsForm } from "@/feature/room/components/questions-form";
import type { QuestionsFormValues } from "@/feature/room/components/questions-form";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { toastError } from "@/lib/toast";

export function RoomSetupPage() {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const { roomId, setRoomData, currentPlayer, handleRoomCancelled, onSseError } = useRoom();

  const [submitting, setSubmitting] = useState(false);

  useRoomSse(
    roomId,
    {
      [ROOM_SSE_EVENTS.INIT]: (data) => {
        if (data.room.status !== "creation") {
          navigate(`/game/room/${roomId}`);
          return;
        }
        if (data.room.host_id !== currentPlayer?.id) {
          toastError("Only the host can set up questions");
          navigate(`/game/room/new`);
          return;
        }
        setRoomData(data);
      },
      [ROOM_SSE_EVENTS.ROOM_CANCELLED]: handleRoomCancelled,
    },
    { onError: onSseError },
  );

  const handleSubmit = async (values: QuestionsFormValues) => {
    setSubmitting(true);
    const room = await dispatch(handleSaveRoomQuestions(roomId, values.questions));
    setSubmitting(false);
    if (room) navigate(`/game/room/${roomId}`);
  };

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
