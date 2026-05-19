import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useDispatch } from "@/store/hooks";
import { handleJoinRoom } from "@/feature/room/state/room.actions";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CodeSlots } from "@/components/ui/code-slots";
import { OrDivider } from "@/components/ui/or-divider";
import { Typography } from "@/components/ui/typography";
import { toastError } from "@/lib/toast";
import { FloatingText } from "@/components/floating-text";
import { ArrowLeft, Dices, LogIn } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

export function RoomPage() {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const [inviteCode, setInviteCode] = useState("");
  const [joining, setJoining] = useState(false);

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
      <div className="flex flex-col items-center justify-center h-full relative">
        <Button
          variant={"ghost"}
          onClick={() => navigate("..")}
          className="self-start"
        >
          <ArrowLeft className="size-4 stroke-[3px]" />
          <Typography variant="label">Back</Typography>
        </Button>
        <div className="w-full max-w-6xl flex flex-col gap-8 items-center h-full">
          <div className="text-center absolute top-36 z-[0] flex flex-col gap-4">
            <Typography variant="heading">
              <FloatingText text="Ready to play?" />
            </Typography>
            <Typography variant="secondary" className="text-center">
              Spin up a new room, or jump into a friend's with their code.
            </Typography>
          </div>
          <div className="mb-6 flex flex-col items-center w-full max-w-md gap-6 z-[1] h-full justify-center">
            <CartoonButton
              variant="primary"
              size="lg"
              onClick={() => navigate("/game/room/host")}
              className="w-full mb-2"
            >
              <Dices className="size-5 stroke-[3px]" />
              Host
            </CartoonButton>

            <OrDivider />

            <div className="flex flex-col items-center gap-2 w-full relative">
              <Typography variant="label" as="p">
                Enter your invite code
              </Typography>
              <CodeSlots value={inviteCode} onChange={setInviteCode} />
              <CartoonButton
                variant="secondary"
                size="lg"
                onClick={handleJoin}
                disabled={joining}
                className={cn(
                  inviteCode.length == 8 ? "flex" : "invisible",
                  "w-full mt-4",
                  "absolute top-24",
                )}
              >
                <LogIn className="size-5 stroke-[3px]" />
                {joining ? "Joining..." : "Join Room"}
              </CartoonButton>
            </div>
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
