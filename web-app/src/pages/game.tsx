import { useNavigate } from "react-router-dom";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { OrDivider } from "@/components/ui/or-divider";
import { FloatingText } from "@/components/floating-text";
import { IconStreak } from "@/components/decor/streak";
import { Users } from "lucide-react";

export function GamePage() {
  const navigate = useNavigate();

  return (
    <PageLayout title="Game">
      <div className="flex flex-col items-center justify-center h-full gap-8 relative">
        <div className="w-full max-w-6xl flex flex-col gap-8 items-center relative h-full">
          <div className="text-center absolute top-36 z-[0] flex flex-col gap-4">
            <Typography variant="heading">
              <FloatingText text="Ready to play?" />
            </Typography>
            <Typography variant="secondary" className="text-center">
              Sharpen your numbers solo, or rally a crew of up to 10 friends.
            </Typography>
          </div>
          <div className="flex flex-col items-center w-full max-w-md gap-6 z-[1] h-full justify-center">
            <CartoonButton
              className="w-full mb-2"
              size="lg"
              onClick={() => navigate("/game/play")}
            >
              <IconStreak className="size-5" />
              Play solo
            </CartoonButton>

            <OrDivider />

            <CartoonButton
              className="w-full"
              variant="secondary"
              size="lg"
              onClick={() => navigate("/game/room")}
            >
              <Users className="stroke-[3px]" />
              Play with friends
            </CartoonButton>
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
