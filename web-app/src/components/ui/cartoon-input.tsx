import React, { type ReactNode, type InputHTMLAttributes } from "react";
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { typographyVariants } from "./typography";

interface CartoonInputProps extends InputHTMLAttributes<HTMLInputElement> {
  rightSlot?: ReactNode;
}

export const CartoonInput = React.forwardRef<
  HTMLInputElement,
  CartoonInputProps
>(function CartoonInput({ rightSlot, className, ...rest }, ref) {
  const input = (
    <div className="relative">
      <Input
        ref={ref}
        {...rest}
        className={cn(
          typographyVariants({ variant: "body" }),
          "bg-white border-[3px] border-border rounded-md p-4 h-auto shadow-cartoon-sm",
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

  return input;
});
