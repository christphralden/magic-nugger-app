import { useEffect, useState } from "react";
import { Typography } from "./typography";
import { Timer as TimerIcon } from "lucide-react";
import { cn } from "@/lib/utils";

function formatCountdown(ms: number): string {
  const totalSecs = Math.max(0, Math.ceil(ms / 1000));
  const mins = Math.floor(totalSecs / 60);
  const secs = totalSecs % 60;
  return `${mins}:${secs.toString().padStart(2, "0")}`;
}
export const Timer = ({
  end,
  onEnd,
}: {
  end: number | null;
  onEnd: () => void;
}) => {
  const [timeLeft, setTimeLeft] = useState<number | null>(null);
  useEffect(() => {
    if (!end) return;

    const tick = () => {
      const remaining = end - Date.now();
      if (remaining <= 0) {
        setTimeLeft(0);
        onEnd();

        return;
      }
      setTimeLeft(remaining);
    };

    tick();
    const interval = setInterval(tick, 1000);
    return () => clearInterval(interval);
  }, [end]);

  if (timeLeft == null) return null;

  return (
    <div className="flex items-center text-ink-soft justify-between w-[3.15rem]">
      <TimerIcon
        className={cn(
          timeLeft < 60_000 ? "text-coral" : "text-ink-soft",
          "size-4 stroke-[3px]",
        )}
      />
      <Typography
        variant="label"
        className={timeLeft < 60_000 ? "text-coral" : "text-ink-soft"}
      >
        {formatCountdown(timeLeft)}
      </Typography>
    </div>
  );
};
