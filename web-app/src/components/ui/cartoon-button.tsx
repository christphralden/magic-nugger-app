import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { Button, type ButtonProps } from "@/components/ui/button";

const cartoonButtonVariants = cva(
  "font-display font-bold tracking-wide inline-flex items-center justify-center gap-2.5 cursor-pointer transition-all duration-[120ms] ease-out active:translate-y-1 select-none whitespace-nowrap border-[3px] border-ink shadow-cartoon active:shadow-[0_2px_0_0_#2A1B3D]",
  {
    variants: {
      variant: {
        primary: "bg-coral text-white hover:brightness-105",
        secondary: "bg-white text-ink hover:bg-cream",
        ghost: "border-transparent shadow-none bg-transparent text-ink hover:bg-black/[0.06] active:translate-y-0",
      },
      size: {
        default: "px-7 py-4 text-lg rounded-cartoon-lg",
        lg: "px-[38px] py-[22px] text-[22px] rounded-cartoon-xl",
        xl: "px-11 py-[26px] text-[26px] rounded-cartoon-xl",
      },
    },
    defaultVariants: {
      variant: "primary",
      size: "default",
    },
  }
);

interface CartoonButtonProps
  extends Omit<ButtonProps, "variant" | "size">,
    VariantProps<typeof cartoonButtonVariants> {}

export function CartoonButton({ variant, size, className, ...props }: CartoonButtonProps) {
  return (
    <Button
      className={cn(cartoonButtonVariants({ variant, size }), className)}
      {...props}
    />
  );
}
