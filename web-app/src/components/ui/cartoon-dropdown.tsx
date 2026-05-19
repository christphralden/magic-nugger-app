import { type ReactNode } from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { typographyVariants } from "./typography";

interface CartoonDropdownItem {
  label: string;
  onClick: () => void;
  disabled?: boolean;
}

interface CartoonDropdownProps {
  trigger: ReactNode;
  items: CartoonDropdownItem[];
  className?: string;
}

export function CartoonDropdown({
  trigger,
  items,
  className,
}: CartoonDropdownProps) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        className={cn(
          typographyVariants({ variant: "body" }),
          "w-full bg-white border-[3px] border-border rounded-md p-4 h-auto",
          "flex items-center justify-between gap-2",
          "outline-none transition-all duration-[120ms]",
          "focus:ring-0 focus:ring-offset-0 focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]",
          className,
        )}
      >
        {trigger}
        <ChevronDown className="h-4 w-4 shrink-0 opacity-50" />
      </DropdownMenuTrigger>
      <DropdownMenuContent className="bg-white border-[3px] border-border rounded-md shadow-cartoon-sm overflow-hidden mt-1 w-[var(--radix-dropdown-menu-trigger-width)]">
        {items.map((item) => (
          <DropdownMenuItem
            key={item.label}
            onClick={item.onClick}
            disabled={item.disabled}
            className={cn(
              typographyVariants({ variant: "body" }),
              "cursor-pointer focus:bg-cream data-[highlighted]:bg-cream rounded py-2.5 pl-8",
            )}
          >
            {item.label}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
