import { type ReactNode, type InputHTMLAttributes } from "react";
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface CartoonInputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  rightSlot?: ReactNode;
}

export function CartoonInput({
  label,
  rightSlot,
  className,
  ...rest
}: CartoonInputProps) {
  const input = (
    <div className="relative">
      <Input
        {...rest}
        className={cn(
          "bg-paper border-[3px] border-ink rounded-cartoon-md p-4 text-[17px] text-ink font-semibold h-auto",
          "outline-none transition-all duration-[120ms]",
          "placeholder:text-placeholder placeholder:font-medium",
          "focus-visible:ring-0 focus-visible:ring-offset-0 focus:bg-white focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]",
          rightSlot && "pr-12",
          className,
        )}
      />
      {rightSlot && (
        <div className="absolute right-3 top-1/2 -translate-y-1/2">
          {rightSlot}
        </div>
      )}
    </div>
  );

  if (!label) return input;

  return (
    <div>
      <Label className="font-display font-semibold text-ink text-[15px] tracking-wide mb-2">
        {label}
      </Label>
      {input}
    </div>
  );
}
