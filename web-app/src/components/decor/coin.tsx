interface CoinProps {
  size?: number;
}

export function Coin({ size = 36 }: CoinProps) {
  return (
    <svg viewBox="0 0 40 40" width={size} height={size}>
      <circle cx="20" cy="20" r="17" fill="#FFB627" stroke="#2A1B3D" strokeWidth="3" />
      <circle cx="20" cy="20" r="11" fill="none" stroke="#E89500" strokeWidth="2.5" />
      <text
        x="20"
        y="25"
        textAnchor="middle"
        fontFamily="Fredoka, sans-serif"
        fontWeight="700"
        fontSize="14"
        fill="#2A1B3D"
      >
        +
      </text>
    </svg>
  );
}
