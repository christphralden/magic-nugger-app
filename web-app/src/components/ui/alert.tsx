import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { Typography } from "@/components/ui/typography";
import { type HTMLAttributes } from "react";
import { Sparkle } from "../decor/sparkle";
import { AlertWarningIcon, AlertErrorIcon } from "@/components/ui/alert-icons";

const alertVariants = cva(
  "border-[3px] border-ink rounded-lg p-3 flex items-center gap-3 text-left shadow-cartoon-sm",
  {
    variants: {
      variant: {
        info: "bg-white",
        error: "bg-white",
        warning: "bg-white",
        success: "bg-white",
      },
    },
    defaultVariants: { variant: "info" },
  },
);

const ALERT_ICONS = {
  info: <Sparkle size={28} className="shrink-0 text-gold" />,
  error: <AlertErrorIcon size={28} className="shrink-0 text-red-400" />,
  warning: <AlertWarningIcon size={28} className="shrink-0 text-amber-500" />,
  success: <Sparkle size={28} className="shrink-0 text-green-500" />,
} as const;

interface AlertProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof alertVariants> {
  title?: string;
  description?: string;
}

export function Alert({
  variant = "info",
  title,
  description,
  className,
  ...props
}: AlertProps) {
  return (
    <div className={cn(alertVariants({ variant }), className)} {...props}>
      {ALERT_ICONS[variant ?? "info"]}
      <div>
        {title && (
          <Typography as="div" variant="label" className="font-bold">
            {title}
          </Typography>
        )}
        {description && (
          <Typography as="div" variant="caption">
            {description}
          </Typography>
        )}
      </div>
    </div>
  );
}
