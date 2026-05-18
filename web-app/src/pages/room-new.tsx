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
import { CartoonInput } from "@/components/ui/cartoon-input";
import { Typography } from "@/components/ui/typography";
import { toastError } from "@/lib/toast";
import { FloatingText } from "@/components/floating-text";

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
    const room = await dispatch(
      handleCreateRoom({
        level_id: 1,
        max_players: 10,
      }),
    );
    if (room) navigate(`/game/room/${room.id}`);
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
        <div className="text-center absolute top-36 h-full w-full z-[0]">
          <Typography variant="heading">
            <FloatingText text="Ready to play?" />
          </Typography>
        </div>
        <div className="flex flex-col items-center w-full max-w-xs gap-2 z-[1]">
          <CartoonButton
            variant={"primary"}
            size={"lg"}
            onClick={handleCreate}
            disabled={creating}
            className="w-full mb-1"
          >
            {creating ? "Creating..." : "Create Room"}
          </CartoonButton>

          <Typography variant="secondary">OR</Typography>

          <div className="flex flex-col gap-1">
            <Typography variant="label" className="text-ink-soft">
              Invite code
            </Typography>
            <CartoonInput
              placeholder="e.g. A1B2C3D4"
              value={inviteCode}
              onChange={(e) => setInviteCode(e.target.value.toUpperCase())}
              maxLength={8}
            />
            <CartoonButton
              variant="secondary"
              size={"lg"}
              onClick={handleJoin}
              disabled={joining}
              className="w-full"
            >
              {joining ? "Joining..." : "Join Room"}
            </CartoonButton>
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
