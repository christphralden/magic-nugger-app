import { SelectHTMLAttributes } from "react";

interface SelectOption {
  value: string;
  label: string;
}

interface CartoonSelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label: string;
  options: ReadonlyArray<SelectOption>;
}

export function CartoonSelect({ label, options, className = "", ...rest }: CartoonSelectProps) {
  return (
    <div>
      <label className="block font-display font-semibold text-ink text-[15px] tracking-wide mb-2">{label}</label>
      <select
        {...rest}
        className={[
          "w-full bg-paper border-[3px] border-ink rounded-cartoon-md px-[18px] py-4 text-[17px] text-ink font-semibold",
          "outline-none appearance-none cursor-pointer transition-all duration-[120ms]",
          "focus:bg-white focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]",
          "bg-[url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%232A1B3D' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>\")] bg-no-repeat bg-[right_14px_center] bg-[length:18px]",
          "pr-11",
          className,
        ]
          .filter(Boolean)
          .join(" ")}
      >
        {options.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
    </div>
  );
}
