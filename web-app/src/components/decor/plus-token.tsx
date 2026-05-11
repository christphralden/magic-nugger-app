interface PlusTokenProps {
  size?: number;
  op?: string;
  bgClass?: string;
}

export function PlusToken({ size = 40, op = "+" }: PlusTokenProps) {
  return (
    <svg viewBox="0 0 50 50" width={size} height={size}>
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
