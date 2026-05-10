import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { Typography } from "@/components/ui/typography";
import { type ReactNode, type HTMLAttributes } from "react";

const alertVariants = cva(
  "border-[3px] border-ink rounded-lg p-4 flex items-center gap-3 text-left",
  {
    variants: {
      variant: {
        info: "bg-cream-2",
        error: "bg-white",
        warning: "bg-cream",
        success: "bg-white",
      },
    },
    defaultVariants: { variant: "info" },
  },
);

interface AlertProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof alertVariants> {
  icon?: ReactNode;
  title?: string;
  description?: string;
}

export function Alert({ variant, icon, title, description, className, ...props }: AlertProps) {
  return (
    <div className={cn(alertVariants({ variant }), className)} {...props}>
      {icon}
      <div>
        {title && (
          <Typography as="div" variant="label" className="font-bold">
            {title}
          </Typography>
        )}
        {description && (
          <Typography as="div" variant="caption" className="text-[12px] text-ink-soft font-semibold">
            {description}
          </Typography>
        )}
      </div>
    </div>
  );
}
