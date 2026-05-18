import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useSelector, useDispatch } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import {
  selectActiveLevels,
  selectLevelsStatus,
  selectUnlockedLevelNames,
} from "@/feature/levels/state/levels.slice";
import {
  handleGetLevels,
  handleGetUnlockedLevels,
} from "@/feature/levels/state/levels.actions";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { cn } from "@/lib/utils";
import { Lock } from "lucide-react";
import { IconStreak } from "@/components/decor/streak";
import { LevelCardSkeleton } from "@/feature/levels/level-card-skeleton";
import { FloatingText } from "@/components/floating-text";

export function LevelSelectPage() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const currentPlayer = useSelector(selectCurrentPlayer);
  const levels = useSelector(selectActiveLevels);
  const levelsStatus = useSelector(selectLevelsStatus);
  const unlockedNames = useSelector(selectUnlockedLevelNames);

  useEffect(() => {
    dispatch(handleGetLevels());
    dispatch(handleGetUnlockedLevels());
  }, [dispatch]);

  if (!currentPlayer) return null;

  return (
    <PageLayout title="Levels">
      <div className="max-w-6xl mx-auto">
        <Typography variant="subheading" className="mb-6">
          Levels
        </Typography>

        {levelsStatus === "loading" && (
          <div className="flex flex-col gap-6">
            {Array.from({ length: 3 }).map((_, i) => (
              <LevelCardSkeleton key={i} />
            ))}
          </div>
        )}

        {levelsStatus !== "loading" && levels.length === 0 && (
          <div className="w-full justify-center text-center">
            <Typography variant={"primary"}>
              <FloatingText text={"No levels available yet :("} duration={1} />
            </Typography>
          </div>
        )}

        <div className="flex flex-col gap-6">
          {levels.map((level) => {
            const isAccessible = unlockedNames.includes(level.name);

            return (
              <div
                key={level.id}
                className={cn(
                  "bg-paper border-[3px] border-border rounded-md shadow-cartoon p-6",
                  !isAccessible && "opacity-50 pointer-events-none",
                )}
              >
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      {!isAccessible && (
                        <Lock className="size-4 text-ink-soft shrink-0" />
                      )}
                      <Typography variant="secondary">{level.name}</Typography>
                      <div className="flex items-center">
                        <IconStreak className="text-coral size-5" />
                        <Typography variant="body">{level.elo_min}</Typography>
                      </div>
                    </div>
                    {level.description && (
                      <Typography variant="label" className="line-clamp-2">
                        {level.description}
                      </Typography>
                    )}
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <CartoonButton
                      variant="secondary"
                      onClick={() =>
                        navigate(`/leaderboard?tab=level&level=${level.id}`)
                      }
                    >
                      Leaderboard
                    </CartoonButton>
                    <CartoonButton
                      variant="primary"
                      onClick={() => navigate(`/game?level=${level.id}`)}
                    >
                      Play!
                    </CartoonButton>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </PageLayout>
  );
}
