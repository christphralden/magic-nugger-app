import { useNavigate } from "react-router-dom";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { OrDivider } from "@/components/ui/or-divider";
import { FloatingText } from "@/components/floating-text";

function FlameIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      width={22}
      height={22}
      fill="currentColor"
      aria-hidden
    >
      <path d="M13.5 0.7C14.2 4.2 11 6.5 10 9c-1.2 3 0.4 5.6 2.5 5.4-0.6-1.6 0.3-3 1.5-3.8 0.3 2 2 3.2 3 5.3 1.5 3.2-0.6 7.3-5 8.1-5 0.9-9-3-8.4-7.6C4 11 8 9 9 5 9.6 2.6 11.6 1.4 13.5 0.7z" />
    </svg>
  );
}

function PeopleIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      width={22}
      height={22}
      fill="none"
      stroke="currentColor"
      strokeWidth="2.6"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <circle cx="9" cy="8" r="4" />
      <path d="M2 21a7 7 0 0 1 14 0" />
      <circle cx="18" cy="9" r="3" />
      <path d="M22 19a5 5 0 0 0-7-4.5" />
    </svg>
  );
}

export function GamePage() {
  const navigate = useNavigate();

  return (
    <PageLayout title="Game">
      <div className="flex flex-col items-center justify-center h-full gap-8 relative">
        <div className="text-center absolute top-36 h-full w-full z-[0] flex flex-col gap-4">
          <Typography variant="heading">
            <FloatingText text="Ready to play?" />
          </Typography>
          <Typography variant="secondary" className="text-center">
            Sharpen your numbers solo, or rally a crew of up to 10 friends.
          </Typography>
        </div>
        <div className="flex flex-col gap-6 w-full max-w-md justify-center z-[1] items-center">
          <CartoonButton
            className="w-full mb-2"
            size="lg"
            onClick={() => navigate("/game/new")}
          >
            <FlameIcon />
            Play solo
          </CartoonButton>

          <OrDivider />

          <CartoonButton
            className="w-full"
            variant="secondary"
            size="lg"
            onClick={() => navigate("/game/room/new")}
          >
            <PeopleIcon />
            Play with friends
          </CartoonButton>
        </div>
      </div>
    </PageLayout>
  );
}
