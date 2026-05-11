import { Link } from "react-router-dom";
import { useSelector } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { PageLayout } from "@/components/layout/page-layout";
import { Alert } from "@/components/ui/alert";

function HomePage() {
  const currentPlayer = useSelector(selectCurrentPlayer)!;
  const profileIncomplete =
    currentPlayer.age === null ||
    currentPlayer.grade === null ||
    currentPlayer.guardian_email === null;

  return (
    <PageLayout title="Home">
      {profileIncomplete && (
        <Link to="/profile">
          <Alert
            variant="warning"
            title="Complete your profile"
            description="Set your age, grade, and guardian email to unlock all features."
            className="mb-6 cursor-pointer hover:opacity-80 transition-opacity"
          />
        </Link>
      )}
    </PageLayout>
  );
}

export function HomePageContainer() {
  const currentPlayer = useSelector(selectCurrentPlayer);
  if (!currentPlayer) return null;
  return <HomePage />;
}
