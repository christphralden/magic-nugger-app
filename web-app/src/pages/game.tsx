import { useNavigate } from "react-router-dom";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { FloatingText } from "@/components/floating-text";

export function GamePage() {
  const navigate = useNavigate();

  return (
    <PageLayout title="Game">
      <div className="flex flex-col items-center justify-center h-full gap-8 relative">
        <div className="text-center  absolute top-36 h-full w-full z-[0]">
          <Typography variant="heading">
            <FloatingText text="Ready to play?" />
          </Typography>
        </div>
        <div className="flex flex-col gap-2 w-full max-w-xs justify-center z-[1] items-center ">
          <CartoonButton
            className="w-full mb-1"
            size="lg"
            onClick={() => navigate("/game/new")}
          >
            Play solo
          </CartoonButton>
          <Typography variant="secondary">OR</Typography>
          <CartoonButton
            className="w-full"
            variant="secondary"
            size="lg"
            onClick={() => navigate("/game/room/new")}
          >
            Play with friends
          </CartoonButton>
        </div>
      </div>
    </PageLayout>
  );
}
