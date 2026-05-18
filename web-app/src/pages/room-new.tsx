import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useDispatch } from "@/store/hooks";
import { handleGetLevels } from "@/feature/levels/state/levels.actions";
import {
  handleCreateRoom,
  handleJoinRoom,
} from "@/feature/room/state/room.actions";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CodeSlots } from "@/components/ui/code-slots";
import { OrDivider } from "@/components/ui/or-divider";
import { Typography } from "@/components/ui/typography";
import { toastError } from "@/lib/toast";
import { FloatingText } from "@/components/floating-text";
import { Plus } from "lucide-react";

export function NewRoomPage() {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const [inviteCode, setInviteCode] = useState("");
  const [creating, setCreating] = useState(false);
  const [joining, setJoining] = useState(false);

  useEffect(() => {
    dispatch(handleGetLevels());
  }, [dispatch]);

  const handleCreate = async () => {
    setCreating(true);
    const room = await dispatch(handleCreateRoom({ max_players: 10 }));
    if (room) navigate(`/game/room/${room.id}/setup`);
    setCreating(false);
  };

  const handleJoin = async () => {
    const code = inviteCode.trim().toUpperCase();
    if (!code) {
      toastError("Enter an invite code");
      return;
    }
    setJoining(true);
    const room = await dispatch(handleJoinRoom(code));
    if (room) navigate(`/game/room/${room.id}`);
    setJoining(false);
  };

  return (
    <PageLayout title="Rooms">
      <div className="flex flex-col items-center justify-center h-full gap-8 relative">
        <div className="text-center absolute top-36 h-full w-full z-[0] flex flex-col gap-4">
          <Typography variant="heading">
            <FloatingText text="Ready to play?" />
          </Typography>
          <Typography variant="secondary" className="text-center">
            Spin up a new room, or jump into a friend's with their code.
          </Typography>
        </div>
        <div className="flex flex-col items-center w-full max-w-md gap-6 z-[1]">
          <CartoonButton
            variant="primary"
            size="lg"
            onClick={handleCreate}
            disabled={creating}
            className="w-full mb-2"
          >
            <Plus className="size-5 stroke-[5px]" />
            {creating ? "Creating..." : "Create Room"}
          </CartoonButton>

          <OrDivider />

          <div className="flex flex-col items-center gap-2 w-full">
            <Typography variant="label" as="p">
              Invite code
            </Typography>
            <CodeSlots value={inviteCode} onChange={setInviteCode} />
            <CartoonButton
              variant="secondary"
              size="lg"
              onClick={handleJoin}
              disabled={joining}
              className="w-full mt-4"
            >
              {joining ? "Joining..." : "Join Room"}
            </CartoonButton>
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
