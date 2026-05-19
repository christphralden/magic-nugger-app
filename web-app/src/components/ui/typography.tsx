import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { type ElementType, type ComponentPropsWithoutRef } from "react";

export const typographyVariants = cva("", {
  variants: {
    variant: {
      logo: "font-display font-bold text-xl lg:text-3xl text-ink",
      heading:
        "font-display font-bold text-6xl lg:text-8xl tracking-[-0.015em] leading-[0.95em]",
      subheading: "font-display font-semibold text-2xl leading-snug",
      primary:
        "font-display font-bold leading-[0.95] tracking-[-0.015em] text-ink text-2xl lg:text-4xl",
      secondary:
        "font-display font-semibold leading-[0.95] tracking-[-0.015em] text-ink text-xl",
      body: "font-body font-semibold md:text-base text-sm leading-relaxed",
      caption: "font-body font-semibold text-sm",
      label: "font-display font-semibold md:text-base text-sm tracking-wide",
      strong: "font-display font-bold text-4xl text-ink leading-none",
      error:
        "text-coral font-display font-semibold md:text-base text-sm tracking-wide",
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
  return (
    <Tag
      className={cn(typographyVariants({ variant }), className)}
      {...props}
    />
  );
}
