import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { type ElementType, type ComponentPropsWithoutRef } from "react";

const typographyVariants = cva("", {
  variants: {
    variant: {
      display: "font-display font-bold leading-[0.95] tracking-[-0.015em]",
      heading: "font-display font-bold text-4xl leading-tight",
      subheading: "font-display font-semibold text-2xl leading-snug",
      body: "font-body font-semibold text-lg leading-relaxed",
      caption: "font-body font-medium text-sm",
      label: "font-display font-semibold text-[15px] tracking-wide",
    },
  },
  defaultVariants: {
    variant: "body",
  },
});

type TypographyProps<T extends ElementType = "p"> = {
  as?: T;
} & VariantProps<typeof typographyVariants> &
  Omit<ComponentPropsWithoutRef<T>, "as">;

export function Typography<T extends ElementType = "p">({
  as,
  variant,
  className,
  ...props
}: TypographyProps<T>) {
  const Tag = (as ?? "p") as ElementType;
  return <Tag className={cn(typographyVariants({ variant }), className)} {...props} />;
}
