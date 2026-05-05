import { InputHTMLAttributes, ReactNode } from "react";

interface CartoonInputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  rightSlot?: ReactNode;
}

export function CartoonInput({ label, rightSlot, className = "", ...rest }: CartoonInputProps) {
  return (
    <div>
      <label className="block font-display font-semibold text-ink text-[15px] tracking-wide mb-2">{label}</label>
      <div className="relative">
        <input
          {...rest}
          className={[
            "w-full bg-paper border-[3px] border-ink rounded-cartoon-md px-[18px] py-4 text-[17px] text-ink font-semibold",
            "outline-none transition-all duration-[120ms]",
            "placeholder:text-[#9A8AAB] placeholder:font-medium",
            "focus:bg-white focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]",
            rightSlot ? "pr-12" : "",
            className,
          ]
            .filter(Boolean)
            .join(" ")}
        />
        {rightSlot && (
          <div className="absolute right-3 top-1/2 -translate-y-1/2">{rightSlot}</div>
        )}
      </div>
    </div>
  );
}
