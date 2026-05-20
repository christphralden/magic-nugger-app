import { cn } from "@/lib/utils";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { typographyVariants } from "./typography";

interface SelectOption {
  value: string;
  label: string;
}

interface CartoonSelectProps {
  options: ReadonlyArray<SelectOption>;
  value?: string;
  onValueChange?: (value: string) => void;
  placeholder?: string;
  className?: string;
}

export function CartoonSelect({
  options,
  value,
  onValueChange,
  placeholder,
  className,
}: CartoonSelectProps) {
  return (
    <div>
      <Select value={value} onValueChange={onValueChange}>
        <SelectTrigger
          className={cn(
            typographyVariants({ variant: "body" }),
            "shadow-cartoon-sm w-full bg-white border-[3px] border-border rounded-md p-4 py-3 h-auto",
            "outline-none transition-all duration-[120ms]",
            className,
          )}
        >
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent className="bg-white border-[3px] border-border rounded-md shadow-cartoon-sm overflow-hidden mt-1">
          {options.map((opt) => (
            <SelectItem
              key={opt.value}
              value={opt.value}
              className={cn(
                typographyVariants({ variant: "body" }),
                "cursor-pointer focus:bg-cream data-[highlighted]:bg-cream rounded py-3 pl-8",
              )}
            >
              {opt.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
}
