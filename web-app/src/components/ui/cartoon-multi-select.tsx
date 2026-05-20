import { ChevronDown, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { typographyVariants } from "./typography";
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "./dropdown-menu";

interface CartoonMultiSelectProps {
  options: string[];
  value: string[];
  onChange: (value: string[]) => void;
  placeholder?: string;
  className?: string;
}

export function CartoonMultiSelect({
  options,
  value,
  onChange,
  placeholder = "Select...",
  className,
}: CartoonMultiSelectProps) {
  const toggle = (item: string) => {
    if (value.includes(item)) {
      onChange(value.filter((v) => v !== item));
    } else {
      onChange([...value, item]);
    }
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          className={cn(
            typographyVariants({ variant: "body" }),
            "min-h-[46px] w-full bg-white border-[3px] border-border rounded-md px-4 py-3",
            "shadow-cartoon-sm flex flex-wrap gap-1.5 items-center text-left",
            "focus:outline-none focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]",
            className,
          )}
        >
          <span className="flex-1 flex flex-wrap gap-1.5">
            {value.length === 0 ? (
              <span className="text-placeholder">{placeholder}</span>
            ) : (
              value.map((v) => (
                <span
                  key={v}
                  className="flex items-center gap-1 bg-cream border-[2px] border-border rounded px-2 py-0.5 text-sm font-body"
                  onClick={(e) => {
                    e.stopPropagation();
                    toggle(v);
                  }}
                >
                  {v}
                  <X className="size-3 hover:text-coral transition-colors" />
                </span>
              ))
            )}
          </span>
          <ChevronDown className="size-4 text-ink-soft shrink-0 ml-auto" />
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent
        className="w-[var(--radix-dropdown-menu-trigger-width)] bg-white border-[3px] border-border rounded-md shadow-cartoon-sm p-1"
        align="start"
      >
        {options.length === 0 ? (
          <p
            className={cn(
              typographyVariants({ variant: "body" }),
              "px-2 py-1.5 text-ink-soft",
            )}
          >
            No options
          </p>
        ) : (
          options.map((opt) => (
            <DropdownMenuCheckboxItem
              key={opt}
              checked={value.includes(opt)}
              onCheckedChange={() => toggle(opt)}
              className={cn(
                typographyVariants({ variant: "body" }),
                "cursor-pointer focus:bg-cream data-[highlighted]:bg-cream rounded py-2 pl-8",
              )}
            >
              {opt}
            </DropdownMenuCheckboxItem>
          ))
        )}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
