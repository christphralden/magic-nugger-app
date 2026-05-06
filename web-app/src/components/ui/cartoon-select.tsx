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
  label: string;
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
      <Label className="font-display font-semibold text-ink text-[15px] tracking-wide mb-2">
        {label}
      </Label>
      <Select value={value} onValueChange={onValueChange}>
        <SelectTrigger
          className={cn(
            "w-full bg-paper border-[3px] border-ink rounded-cartoon-md px-[18px] py-4 h-auto",
            "text-[17px] text-ink font-semibold outline-none transition-all duration-[120ms]",
            "focus:ring-0 focus:ring-offset-0 focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]",
            className
          )}
        >
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent>
          {options.map((opt) => (
            <SelectItem key={opt.value} value={opt.value}>
              {opt.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
}
