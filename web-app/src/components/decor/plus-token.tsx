import { TEAL } from "@/constants/colors";

interface PlusTokenProps {
  size?: number;
  op?: string;
  bg?: string;
}

export function PlusToken({ size = 40, op = "+", bg = TEAL }: PlusTokenProps) {
  return (
    <svg viewBox="0 0 50 50" width={size} height={size}>
      <rect x="3" y="3" width="44" height="44" rx="10" fill={bg} stroke="#2A1B3D" strokeWidth="3" />
      <text
        x="25"
        y="34"
        textAnchor="middle"
        fontFamily="Fredoka, sans-serif"
        fontWeight="700"
        fontSize="26"
        fill="#2A1B3D"
      >
        {op}
      </text>
    </svg>
  );
}
