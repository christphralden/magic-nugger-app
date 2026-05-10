import { cn } from "@/lib/utils";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface SelectOption {
  value: string;
  label: string;
}

interface CartoonSelectProps {
  label?: string;
  options: ReadonlyArray<SelectOption>;
  value?: string;
  onValueChange?: (value: string) => void;
  placeholder?: string;
  className?: string;
}

export function CartoonSelect({
  label,
  options,
  value,
  onValueChange,
  placeholder,
  className,
}: CartoonSelectProps) {
  return (
    <div>
      {label && (
        <Label className="font-display font-semibold text-ink text-[15px] tracking-wide">
          {label}
        </Label>
      )}
      <Select value={value} onValueChange={onValueChange}>
        <SelectTrigger
          className={cn(
            "w-full bg-paper border-[3px] border-ink rounded-cartoon-md p-4 py-[0.85rem] h-auto",
            "text-[17px] text-ink font-semibold outline-none transition-all duration-[120ms]",
            "focus:ring-0 focus:ring-offset-0 focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]",
            className,
          )}
        >
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent className="bg-paper border-[3px] border-ink rounded-cartoon-md shadow-cartoon overflow-hidden mt-1">
          {options.map((opt) => (
            <SelectItem
              key={opt.value}
              value={opt.value}
              className="text-ink font-semibold cursor-pointer focus:bg-cream-2 focus:text-ink data-[highlighted]:bg-cream-2 rounded py-2.5 pl-8 text-base"
            >
              {opt.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
}
