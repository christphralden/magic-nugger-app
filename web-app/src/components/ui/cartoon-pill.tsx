import { cn } from "@/lib/utils";

export function CartoonPill({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "cursor-pointer inline-flex items-center gap-1.5 border-[2.5px] border-border rounded-full px-[14px] py-1.5 font-display font-semibold text-[14px] shadow-cartoon-sm",
        className,
      )}
    >
      {children}
    </span>
  );
}
