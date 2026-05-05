import { GOLD } from "@/constants/colors";

interface SparkleProps {
  size?: number;
  color?: string;
}

export function Sparkle({ size = 24, color = GOLD }: SparkleProps) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size}>
      <path
        d="M12 1 L14 10 L23 12 L14 14 L12 23 L10 14 L1 12 L10 10 Z"
        fill={color}
        stroke="#2A1B3D"
        strokeWidth="1.6"
        strokeLinejoin="round"
      />
    </svg>
  );
}
