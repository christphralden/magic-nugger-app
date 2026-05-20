import { useEffect } from "react";
import * as DialogPrimitive from "@radix-ui/react-dialog";
import { DialogOverlay, DialogPortal } from "@/components/ui/dialog";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { LevelLeaderboardTable } from "@/feature/leaderboard/components/level-leaderboard-table";
import { handleGetLevelLeaderboard } from "@/feature/leaderboard/state/leaderboard.actions";
import { selectLevelLeaderboard } from "@/feature/leaderboard/state/leaderboard.slice";
import { useDispatch, useSelector } from "@/store/hooks";
import type {
  LevelLeaderboardRow,
  ResponsePlayer,
} from "@magic-nugger-app/shared";

type Props = {
  open: boolean;
  onClose: () => void;
  levelId: number;
  levelName: string;
  score: number;
  currentPlayer: ResponsePlayer;
};

export function SessionEndDialog({
  open,
  onClose,
  levelId,
  levelName,
  score,
  currentPlayer,
}: Props) {
  const dispatch = useDispatch();
  const levelState = useSelector((state) =>
    selectLevelLeaderboard(state, levelId),
  );

  useEffect(
    function fetchLeaderboard() {
      if (!open) return;
      dispatch(handleGetLevelLeaderboard({ levelId, limit: 10 }));
    },
    [open, levelId, dispatch],
  );

  function handleOpenChange(isOpen: boolean) {
    if (!isOpen) onClose();
  }

  const myRow: LevelLeaderboardRow = {
    player_id: currentPlayer.id,
    username: currentPlayer.username,
    display_name: currentPlayer.display_name,
    avatar_url: currentPlayer.avatar_url,
    best_score: score,
    max_streak: currentPlayer.longest_streak,
  };

  return (
    <DialogPrimitive.Root open={open} onOpenChange={handleOpenChange}>
      <DialogPortal>
        <DialogOverlay className="bg-ink/50 backdrop-blur-sm" />
        <DialogPrimitive.Content className="fixed left-1/2 top-1/2 z-50 w-full max-w-2xl -translate-x-1/2 -translate-y-1/2 bg-paper border-[3px] border-border rounded-xl shadow-cartoon-lg p-4 px-6 flex flex-col gap-6 focus:outline-none">
          <div className="flex flex-col gap-1">
            <DialogPrimitive.Title asChild>
              <Typography variant="primary">{levelName}</Typography>
            </DialogPrimitive.Title>
            {levelName && (
              <DialogPrimitive.Description asChild>
                <Typography variant="secondary" className="text-ink-soft">
                  Score: {score}
                </Typography>
              </DialogPrimitive.Description>
            )}
          </div>

          <div className="bg-white border-[3px] border-border rounded-md shadow-cartoon overflow-hidden">
            <LevelLeaderboardTable
              items={levelState.items}
              currentPlayerId={currentPlayer.id}
              isLoading={levelState.status === "loading"}
              currentSessionEntry={myRow}
            />
          </div>

          <div className="flex justify-end">
            <CartoonButton size="sm" onClick={onClose}>
              Close
            </CartoonButton>
          </div>
        </DialogPrimitive.Content>
      </DialogPortal>
    </DialogPrimitive.Root>
  );
}
