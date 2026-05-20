import { useEffect } from "react";
import { formatDistanceToNow } from "date-fns";
import { useNavigate } from "react-router-dom";
import { useDispatch, useSelector } from "@/store/hooks";
import {
  handleCreateRoom,
  handleGetRooms,
} from "@/feature/room/state/room.actions";
import { selectRoomCreateStatus } from "@/feature/room/state/room.slice";
import {
  selectRooms,
  selectRoomsStatus,
} from "@/feature/room/state/rooms.slice";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { FloatingText } from "@/components/floating-text";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Plus } from "lucide-react";
import type { Room, RoomStatus } from "@magic-nugger-app/shared";
import { cn } from "@/lib/utils";

const STATUS_LABELS: Record<RoomStatus, string> = {
  creation: "Setting up since",
  waiting: "In lobby for",
  in_progress: "In game for",
  completed: "Completed",
  cancelled: "Cancelled",
};

const STATUS_COLORS: Record<RoomStatus, string> = {
  creation: "text-ink-soft",
  waiting: "text-ink-soft",
  in_progress: "text-ink-soft",
  completed: "text-ink-soft",
  cancelled: "text-ink-soft",
};

const RESUME_LABELS: Record<RoomStatus, string> = {
  creation: "Resume setup",
  waiting: "Resume room",
  in_progress: "View leaderboard",
  completed: "View leaderboard",
  cancelled: "",
};

export function RoomHostPage() {
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const rooms = useSelector(selectRooms);
  const roomsStatus = useSelector(selectRoomsStatus);
  const createStatus = useSelector(selectRoomCreateStatus);

  const loading = roomsStatus === "idle" || roomsStatus === "loading";
  const creating = createStatus === "loading";

  useEffect(() => {
    dispatch(handleGetRooms());
  }, [dispatch]);

  const handleCreate = async () => {
    const room = await dispatch(handleCreateRoom({ max_players: 10 }));
    if (room) navigate(`/game/room/${room.id}/setup`);
  };

  const handleRedirect = (room: Room) => {
    if (room.status === "creation") navigate(`/game/room/${room.id}/setup`);
    if (room.status === "waiting") navigate(`/game/room/${room.id}`);
    if (room.status === "in_progress")
      navigate(`/game/room/${room.id}/finished`);
    if (room.status === "completed") navigate(`/game/room/${room.id}/finished`);
  };

  const filteredRooms = rooms;

  return (
    <PageLayout title="Host">
      <div className="flex flex-col items-center relative z-[1]">
        <Button
          variant="ghost"
          onClick={() => navigate("..")}
          className="self-start"
        >
          <ArrowLeft className="size-4 stroke-[3px]" />
          <Typography variant="label">Back</Typography>
        </Button>
        <div className="w-full h-full max-w-3xl flex flex-col gap-8 items-center">
          <div className="text-center flex flex-col gap-2">
            <Typography variant="heading">
              <FloatingText text="Host a game" duration={2} />
            </Typography>
            <Typography variant="secondary">
              Resume an active room or start a new one.
            </Typography>
          </div>
          {roomsStatus !== "loading" && filteredRooms.length > 0 && (
            <CartoonButton
              variant="primary"
              size={"sm"}
              onClick={handleCreate}
              disabled={creating}
              className="w-fit self-start"
            >
              <Plus className="size-5 stroke-[4px]" />
              {creating ? "Creating..." : "New room"}
            </CartoonButton>
          )}
          {loading ? (
            <div className="flex justify-center py-8">
              <Typography variant="secondary" className="text-ink-soft">
                Loading...
              </Typography>
            </div>
          ) : (
            <div className="flex flex-col gap-4 max-w-3xl w-full">
              {filteredRooms.length > 0 ? (
                <div className="flex flex-col gap-3">
                  {filteredRooms.map((room) => (
                    <div
                      key={room.id}
                      className={cn(
                        (room.status === "completed" ||
                          room.status === "cancelled") &&
                          "brightness-75",
                        "bg-paper border-[3px] border-border rounded-2xl shadow-cartoon-sm p-4 flex items-center justify-between gap-4",
                      )}
                    >
                      <div className="flex flex-col gap-1.5">
                        <div className="flex items-center">
                          <Typography
                            variant="label"
                            className={STATUS_COLORS[room.status]}
                            as="span"
                          >
                            {STATUS_LABELS[room.status]}
                          </Typography>
                          &nbsp;
                          <Typography
                            variant="label"
                            className="text-ink-soft"
                            as="span"
                          >
                            {formatDistanceToNow(new Date(room.updated_at), {
                              addSuffix: true,
                            })}
                          </Typography>
                        </div>
                        <Typography
                          variant="primary"
                          className="tracking-[0.2em]"
                        >
                          {room.invite_code}
                        </Typography>
                      </div>
                      <CartoonButton
                        size="sm"
                        onClick={() => handleRedirect(room)}
                        className="shrink-0"
                      >
                        {RESUME_LABELS[room.status]}
                      </CartoonButton>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-16 flex flex-col items-center gap-4">
                  <Typography
                    variant={"label"}
                    className="max-w-xs mx-auto text-center"
                  >
                    Click the button below to start playing with friends
                  </Typography>
                  <CartoonButton
                    variant="primary"
                    size={"sm"}
                    onClick={handleCreate}
                    disabled={creating}
                    className="w-fit "
                  >
                    <Plus className="size-5 stroke-[4px]" />
                    {creating ? "Creating..." : "New room"}
                  </CartoonButton>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </PageLayout>
  );
}
