import { OTPInput, OTPInputContext } from "input-otp";
import { useContext } from "react";
import { cn } from "@/lib/utils";

interface CodeSlotsProps {
  value: string;
  length?: number;
  onChange?: (value: string) => void;
  className?: string;
}

function Slot({ index }: { index: number }) {
  const ctx = useContext(OTPInputContext);
  const slot = ctx.slots[index];

  return (
    <div
      className={cn(
        "relative w-10 h-14 border-[3px] border-ink rounded-xl shadow-cartoon-sm flex items-center justify-center font-display font-bold text-2xl text-ink",
        slot.char !== null ? "bg-cream-2" : "bg-paper",
      )}
    >
      {slot.char}
      {slot.isActive && !slot.char && (
        <span className="absolute bottom-2 left-1/2 -translate-x-1/2 w-4 h-[3px] bg-coral rounded-sm animate-pulse" />
      )}
    </div>
  );
}

export function CodeSlots({
  value,
  length = 8,
  onChange,
  className,
}: CodeSlotsProps) {
  return (
    <OTPInput
      maxLength={length}
      value={value}
      onChange={(v) => onChange?.(v.toUpperCase())}
      inputMode="text"
      className={cn("flex gap-2 justify-center", className)}
      containerClassName="flex gap-2 justify-center"
    >
      {Array.from({ length }).map((_, i) => (
        <Slot key={i} index={i} />
      ))}
    </OTPInput>
  );
}
