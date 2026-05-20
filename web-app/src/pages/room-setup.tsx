import { useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { useDispatch } from "@/store/hooks";
import {
  handleSaveRoomQuestions,
  handleOpenRoom,
} from "@/feature/room/state/room.actions";
import { useRoomSse } from "@/hooks/use-room-sse";
import { useRoom } from "@/contexts/room.context";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
import { FloatingText } from "@/components/floating-text";
import { CartoonPill } from "@/components/ui/cartoon-pill";
import { QuestionsForm } from "@/feature/room/components/questions-form";
import type { QuestionsFormValues } from "@/feature/room/components/questions-form";
import { ROOM_SSE_EVENTS } from "@magic-nugger-app/shared";
import { toastError, toastInfo } from "@/lib/toast";
import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";

export function RoomSetupPage() {
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

  const [submitting, setSubmitting] = useState(false);
  const [opening, setOpening] = useState(false);
  const [questionsSaved, setQuestionsSaved] = useState(false);

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
          navigate("/game/room");
          return;
        }
        setRoomData(data);
        if (data.room.questions) {
          setQuestionsSaved(true);
        }
      },
      [ROOM_SSE_EVENTS.ROOM_CANCELLED]: handleRoomCancelled,
    },
    { onError: onSseError },
  );

  const defaultFormValues = useMemo((): QuestionsFormValues | undefined => {
    const questions = roomData?.room.questions as {
      schema: number;
      data: QuestionsFormValues["questions"];
    } | null;
    if (!questions?.data?.length) return undefined;
    return { questions: questions.data };
  }, [roomData?.room.questions]);

  const hasExistingQuestions =
    roomData?.room.questions != null || questionsSaved;

  const handleSave = async (values: QuestionsFormValues): Promise<boolean> => {
    setSubmitting(true);
    const room = await dispatch(
      handleSaveRoomQuestions(roomId, values.questions),
    );
    setSubmitting(false);
    if (room) {
      toastInfo(
        "Questions saved, you can reopen the room by clicking the button again",
      );
      setQuestionsSaved(true);
      return true;
    }
    return false;
  };

  const handleOpen = async () => {
    setOpening(true);
    const room = await dispatch(handleOpenRoom(roomId));
    setOpening(false);
    if (room) navigate(`/game/room/${roomId}`);
  };

  return (
    <PageLayout title="Setup">
      <div className="flex flex-col items-center justify-center h-full relative z-[1]">
        <Button
          variant={"ghost"}
          onClick={() => {
            if (isHost) {
              navigate("/game/room/host");
            } else {
              navigate("/game/room");
            }
          }}
          className="self-start absolute top-0"
        >
          <ArrowLeft className="size-4 stroke-[3px]" />
          <Typography variant="label">Back</Typography>
        </Button>

        <div className="flex justify-center h-full py-4 pt-6">
          <div className="flex flex-col items-center gap-8 max-w-6xl w-full h-full">
            <CartoonPill className="bg-gold hover:animate-nudge mt-4">
              Custom questions
            </CartoonPill>
            <div className="flex flex-col items-center gap-2 text-center">
              <Typography variant="heading">
                <FloatingText text="Build your quiz" duration={2} />
              </Typography>
              <Typography variant="secondary">
                Add problems and mark the correct answer for each
              </Typography>
            </div>

            <div className="w-full max-w-2xl pb-8 flex flex-col">
              {roomData && (
                <QuestionsForm
                  roomId={roomId}
                  onSubmit={handleSave}
                  onOpenRoom={handleOpen}
                  submitting={submitting}
                  opening={opening}
                  hasExistingQuestions={hasExistingQuestions}
                  defaultValues={defaultFormValues}
                />
              )}
            </div>
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
