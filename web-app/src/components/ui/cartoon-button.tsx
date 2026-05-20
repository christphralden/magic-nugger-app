import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { Button, type ButtonProps } from "@/components/ui/button";

const cartoonButtonVariants = cva(
  "hover:brightness-[80%] font-display font-bold tracking-wide inline-flex items-center justify-center gap-2 cursor-pointer transition-all duration-[120ms] ease-out active:translate-y-1 select-none whitespace-nowrap border-[3px] border-ink",
  {
    variants: {
      variant: {
        primary: "bg-coral hover:bg-coral text-white",
        secondary: "bg-white hover:bg-white text-ink",
        select: "bg-cream hover:bg-cream-2 text-ink",
        ghost:
          "border-transparent bg-transparent text-ink active:translate-y-0 hover:bg-accent hover:text-accent-foreground hover:brightness-[100%]",
      },
      size: {
        sm: "px-4 py-4 text-base rounded-xl shadow-cartoon-sm",
        default: "px-8 py-6 text-lg rounded-full shadow-cartoon",
        lg: "px-12 py-8 text-2xl rounded-full shadow-cartoon",
        xl: "px-16 py-10 text-3xl rounded-full shadow-cartoon",
      },
    },
    compoundVariants: [
      { variant: "select", class: "rounded-xl px-4 shadow-cartoon-sm" },
      { variant: "ghost", class: "shadow-none" },
    ],
    defaultVariants: {
      variant: "primary",
      size: "default",
    },
  },
);

interface CartoonButtonProps
  extends Omit<ButtonProps, "variant" | "size">,
    VariantProps<typeof cartoonButtonVariants> {}

export function CartoonButton({
  variant,
  size,
  className,
  ...props
}: CartoonButtonProps) {
  return (
    <Button
      className={cn(cartoonButtonVariants({ variant, size }), className)}
      {...props}
    />
  );
}
