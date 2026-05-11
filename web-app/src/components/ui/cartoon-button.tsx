import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { Button, type ButtonProps } from "@/components/ui/button";

const cartoonButtonVariants = cva(
  "hover:brightness-[80%] items-center font-display font-bold tracking-wide inline-flex items-center justify-center gap-2.5 cursor-pointer transition-all duration-[120ms] ease-out active:translate-y-1 select-none whitespace-nowrap border-[3px] border-ink shadow-cartoon",
  {
    variants: {
      variant: {
        primary: "bg-coral hover:bg-coral text-white",
        secondary: "bg-white hover:bg-white text-ink",
        select:
          "bg-cream hover:bg-cream-2 !rounded-xl shadow-cartoon-sm !px-4 text-ink",
        ghost:
          "border-transparent shadow-none bg-transparent text-ink active:translate-y-0 hover:bg-white",
      },
      size: {
        default: "px-8 py-6 text-lg rounded-full",
        lg: "px-12 py-8 text-2xl rounded-full",
        xl: "px-16 py-10 text-3xl rounded-full",
      },
    },
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
