import { ButtonHTMLAttributes, ReactNode } from "react";

type CartoonButtonVariant = "primary" | "secondary" | "ghost";
type CartoonButtonSize = "default" | "lg" | "xl";

interface CartoonButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: CartoonButtonVariant;
  size?: CartoonButtonSize;
  children?: ReactNode;
}

const VARIANT_CLASSES: Record<CartoonButtonVariant, string> = {
  primary:
    "bg-coral text-white border-[3px] border-ink shadow-cartoon hover:brightness-105 active:shadow-[0_2px_0_0_#2A1B3D]",
  secondary:
    "bg-white text-ink border-[3px] border-ink shadow-cartoon hover:bg-cream active:shadow-[0_2px_0_0_#2A1B3D]",
  ghost: "bg-transparent text-ink border-transparent shadow-none hover:bg-black/[0.06] active:translate-y-0 px-4 py-2.5 text-base",
};

const SIZE_CLASSES: Record<CartoonButtonSize, string> = {
  default: "px-7 py-4 text-lg rounded-cartoon-lg",
  lg: "px-[38px] py-[22px] text-[22px] rounded-cartoon-xl",
  xl: "px-11 py-[26px] text-[26px] rounded-cartoon-xl",
};

export function CartoonButton({
  variant = "primary",
  size = "default",
  className = "",
  children,
  ...rest
}: CartoonButtonProps) {
  return (
    <button
      {...rest}
      className={[
        "inline-flex items-center justify-center gap-2.5 font-display font-bold tracking-wide",
        "transition-all duration-[120ms] ease-out active:translate-y-1",
        "cursor-pointer select-none whitespace-nowrap",
        VARIANT_CLASSES[variant],
        SIZE_CLASSES[size],
        className,
      ]
        .filter(Boolean)
        .join(" ")}
    >
      {children}
    </button>
  );
}
