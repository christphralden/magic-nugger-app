import { PAPER } from "@/constants/colors";

interface CloudProps {
  size?: number;
  color?: string;
}

export function Cloud({ size = 100, color = PAPER }: CloudProps) {
  return (
    <svg viewBox="0 0 120 60" width={size} height={size * 0.5}>
      <path
        d="M20 45 Q5 45 8 30 Q5 18 20 18 Q22 8 38 12 Q48 0 62 8 Q78 4 82 18 Q102 16 105 30 Q115 45 100 48 Q60 54 20 45 Z"
        fill={color}
        stroke="#2A1B3D"
        strokeWidth="3"
        strokeLinejoin="round"
      />
    </svg>
  );
}
