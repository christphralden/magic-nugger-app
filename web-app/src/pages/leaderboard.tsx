import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { useCursor } from "@/hooks/use-cursor";
import { useSelector, useDispatch } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import {
  selectGlobalLeaderboard,
  selectSelectedLevelLeaderboard,
} from "@/feature/leaderboard/state/leaderboard.slice";
import {
  handleGetGlobalLeaderboard,
  handleGetLevelLeaderboard,
} from "@/feature/leaderboard/state/leaderboard.actions";
import {
  selectLevels,
  selectLevelsStatus,
} from "@/feature/levels/state/levels.slice";
import { handleGetLevels } from "@/feature/levels/state/levels.actions";
import { GlobalRow } from "@/feature/leaderboard/components/global-row";
import { LevelRow } from "@/feature/leaderboard/components/level-row";
import { EmptyRow } from "@/feature/leaderboard/components/empty-row";
import { PageLayout } from "@/components/layout/page-layout";
import { Typography } from "@/components/ui/typography";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { cn } from "@/lib/utils";
import { LEADERBOARD_PAGINATION_LIMIT } from "@/constants";
import type { LeaderboardPeriod } from "@magic-nugger-app/shared";
import { ChevronLeft, ChevronRight, Loader2 } from "lucide-react";
import { IconStreak } from "@/components/decor/streak";

type MainTab = "global" | "level";

const PERIODS: { value: LeaderboardPeriod; label: string }[] = [
  { value: "week", label: "Week" },
  { value: "month", label: "Month" },
  { value: "alltime", label: "All Time" },
];

const tabClass = (active: boolean) =>
  cn(
    "inline-flex items-center border-[2.5px] border-border rounded-full px-[14px] py-1.5 font-display font-semibold text-[14px] shadow-cartoon-sm transition-colors cursor-pointer",
    active
      ? "bg-ink text-white border-ink"
      : "bg-white text-ink hover:bg-cream",
  );

export function LeaderboardPage() {
  const currentPlayer = useSelector(selectCurrentPlayer);
  if (!currentPlayer) return null;

  return <LeaderboardContent currentPlayerId={currentPlayer.id} />;
}

function LeaderboardContent({ currentPlayerId }: { currentPlayerId: string }) {
  const dispatch = useDispatch();
  const [searchParams, setSearchParams] = useSearchParams();

  const levels = useSelector(selectLevels);
  const levelsStatus = useSelector(selectLevelsStatus);
  const globalState = useSelector(selectGlobalLeaderboard);

  const [mainTab, setMainTab] = useState<MainTab>(() => {
    const t = searchParams.get("tab");
    return t === "level" ? "level" : "global";
  });
  const [period, setPeriod] = useState<LeaderboardPeriod>(() => {
    const p = searchParams.get("period");
    return (["week", "month", "alltime"] as LeaderboardPeriod[]).includes(
      p as LeaderboardPeriod,
    )
      ? (p as LeaderboardPeriod)
      : "alltime";
  });
  const [selectedLevelId, setSelectedLevelId] = useState<number | null>(() => {
    const l = searchParams.get("level");
    const parsed = l ? parseInt(l, 10) : NaN;
    return isNaN(parsed) ? null : parsed;
  });
  const cursor = useCursor();

  const activeLevels = levels
    .filter((l) => l.is_active)
    .sort((a, b) => a.order_index - b.order_index);

  const levelState = useSelector((state) =>
    selectSelectedLevelLeaderboard(state, selectedLevelId),
  );

  const currentCursor = cursor.current;
  const pageOffset = cursor.pageIndex * LEADERBOARD_PAGINATION_LIMIT;

  const showTable = mainTab === "global" || selectedLevelId !== null;
  const isLoading =
    (mainTab === "global" ? globalState.status : levelState.status) ===
    "loading";
  const activeNextCursor =
    mainTab === "global" ? globalState.next_cursor : levelState.next_cursor;

  useEffect(() => {
    dispatch(handleGetLevels());
  }, [dispatch]);

  useEffect(() => {
    if (mainTab === "global") {
      dispatch(handleGetGlobalLeaderboard({ cursor: currentCursor, period }));
    } else if (selectedLevelId !== null) {
      dispatch(
        handleGetLevelLeaderboard({
          levelId: selectedLevelId,
          cursor: currentCursor,
          period,
        }),
      );
    }
  }, [dispatch, mainTab, selectedLevelId, currentCursor, period]);

  function syncParams(updates: {
    tab?: MainTab;
    level?: number | null;
    period?: LeaderboardPeriod;
  }) {
    setSearchParams((prev) => {
      const next = new URLSearchParams(prev);
      if (updates.tab !== undefined) next.set("tab", updates.tab);
      if (updates.period !== undefined) next.set("period", updates.period);
      if (updates.level !== undefined) {
        if (updates.level === null) next.delete("level");
        else next.set("level", String(updates.level));
      }
      return next;
    });
  }

  function handleMainTab(tab: MainTab) {
    setMainTab(tab);
    setSelectedLevelId(null);
    cursor.reset();
    syncParams({ tab, level: null });
  }

  function handlePeriod(p: LeaderboardPeriod) {
    setPeriod(p);
    cursor.reset();
    syncParams({ period: p });
  }

  function handleLevelSelect(levelId: number) {
    setSelectedLevelId(levelId);
    cursor.reset();
    syncParams({ level: levelId });
  }

  const hasPrev = cursor.hasPrev;
  const hasNext = activeNextCursor !== null;

  function handleNext() {
    if (!hasNext) return;
    cursor.next(activeNextCursor!);
  }

  function handlePrev() {
    if (!hasPrev) return;
    cursor.prev();
  }

  return (
    <PageLayout title="Leaderboard">
      <div className="max-w-6xl mx-auto">
        <Typography variant="subheading" className="mb-6">
          Leaderboard
        </Typography>

        <div className="flex w-full justify-between">
          <div className="flex items-center gap-2 mb-4">
            <button
              className={tabClass(mainTab === "global")}
              onClick={() => handleMainTab("global")}
            >
              Global
            </button>
            <button
              className={tabClass(mainTab === "level")}
              onClick={() => handleMainTab("level")}
            >
              Level
            </button>
          </div>

          <div className="flex items-center gap-3 mb-6">
            <Typography variant="label">Period:</Typography>
            {PERIODS.map(({ value, label }) => (
              <button
                key={value}
                className={tabClass(period === value)}
                onClick={() => handlePeriod(value)}
              >
                {label}
              </button>
            ))}
          </div>
        </div>

        {mainTab === "level" && selectedLevelId === null && (
          <div className="flex flex-wrap gap-2">
            {levelsStatus === "loading" && (
              <Typography variant="body" className="text-ink-soft">
                Loading levels…
              </Typography>
            )}
            {levelsStatus !== "loading" && activeLevels.length === 0 && (
              <Typography variant="body" className="text-ink-soft">
                No levels available.
              </Typography>
            )}
            <div className="flex flex-col w-full gap-4">
              {activeLevels.map((level) => (
                <CartoonButton
                  key={level.id}
                  variant="select"
                  size="default"
                  onClick={() => handleLevelSelect(level.id)}
                >
                  {level.name}
                </CartoonButton>
              ))}
            </div>
          </div>
        )}

        {showTable && (
          <>
            {mainTab === "level" && selectedLevelId !== null && (
              <Typography variant="label" className="mb-3 text-ink-soft">
                Level {">"} {levels.find((l) => l.id === selectedLevelId)?.name}
              </Typography>
            )}
            <div className="bg-white border-[3px] border-border rounded-md shadow-cartoon overflow-hidden">
              {mainTab === "global" ? (
                <ScrollArea className="h-[60dvh]">
                  <Table>
                    <TableHeader>
                      <TableRow header>
                        <TableHead colSpan={1}>
                          <Typography variant="label" className="text-ink-soft">
                            #
                          </Typography>
                        </TableHead>
                        <TableHead colSpan={3}>
                          <Typography variant="label" className="text-ink-soft">
                            Player
                          </Typography>
                        </TableHead>
                        <TableHead
                          colSpan={1}
                          className="text-right min-w-[10rem] max-w-[10rem]"
                        >
                          <div className="flex justify-end items-center">
                            <IconStreak className="size-5 text-coral" />
                            <Typography
                              variant="label"
                              className="text-ink-soft"
                            >
                              ELO
                            </Typography>
                          </div>
                        </TableHead>
                        <TableHead
                          colSpan={1}
                          className="text-right min-w-[10rem] max-w-[10rem]"
                        >
                          <Typography variant="label" className="text-ink-soft">
                            Best Streak
                          </Typography>
                        </TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody className={cn(isLoading && "opacity-50")}>
                      {globalState.items.map((row, i) => (
                        <GlobalRow
                          key={row.id}
                          row={row}
                          rank={pageOffset + i + 1}
                          currentPlayerId={currentPlayerId}
                        />
                      ))}
                      {!isLoading && globalState.items.length === 0 && (
                        <EmptyRow colSpan={4} message="No players yet." />
                      )}
                    </TableBody>
                    {isLoading && (
                      <TableRow>
                        <TableCell colSpan={8}>
                          <Loader2 className="animate-spin mx-auto" />
                        </TableCell>
                      </TableRow>
                    )}
                  </Table>
                </ScrollArea>
              ) : (
                <ScrollArea className="h-[480px]">
                  <Table>
                    <TableHeader>
                      <TableRow header>
                        <TableHead colSpan={1}>
                          <Typography variant="label" className="text-ink-soft">
                            #
                          </Typography>
                        </TableHead>
                        <TableHead colSpan={3} className="w-full">
                          <Typography variant="label" className="text-ink-soft">
                            Player
                          </Typography>
                        </TableHead>
                        <TableHead
                          className="text-right min-w-[10rem]"
                          colSpan={1}
                        >
                          <Typography variant="label" className="text-ink-soft">
                            Best Score
                          </Typography>
                        </TableHead>
                        <TableHead
                          className="text-right min-w-[10rem]"
                          colSpan={1}
                        >
                          <Typography variant="label" className="text-ink-soft">
                            Best Streak
                          </Typography>
                        </TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody className={cn(isLoading && "opacity-50")}>
                      {levelState.items.map((row, i) => (
                        <LevelRow
                          key={row.player_id}
                          row={row}
                          rank={pageOffset + i + 1}
                          currentPlayerId={currentPlayerId}
                        />
                      ))}
                      {!isLoading && levelState.items.length === 0 && (
                        <EmptyRow colSpan={8} message="No scores yet." />
                      )}
                    </TableBody>
                    {isLoading && (
                      <TableRow>
                        <TableCell colSpan={8}>
                          <Loader2 className="animate-spin mx-auto" />
                        </TableCell>
                      </TableRow>
                    )}
                  </Table>
                </ScrollArea>
              )}
            </div>

            <div className="flex items-center justify-between mt-4">
              <Typography variant="label" className="text-ink-soft">
                Page {cursor.pageIndex + 1}
              </Typography>
              <div className="flex gap-2">
                <CartoonButton
                  variant="secondary"
                  size="default"
                  onClick={handlePrev}
                  disabled={!hasPrev}
                  className="!px-4 !py-3 disabled:opacity-40 disabled:cursor-not-allowed"
                >
                  <ChevronLeft className="size-5" />
                </CartoonButton>
                <CartoonButton
                  variant="secondary"
                  size="default"
                  onClick={handleNext}
                  disabled={!hasNext}
                  className="!px-4 !py-3 disabled:opacity-40 disabled:cursor-not-allowed"
                >
                  <ChevronRight className="size-5" />
                </CartoonButton>
              </div>
            </div>
          </>
        )}
      </div>
    </PageLayout>
  );
}
