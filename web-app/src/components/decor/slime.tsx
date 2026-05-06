interface SlimeProps {
  size?: number;
  className?: string;
}

export function Slime({ size = 70, className = "text-green" }: SlimeProps) {
  return (
    <svg viewBox="0 0 80 80" width={size} height={size} className={className}>
      <ellipse cx="40" cy="72" rx="28" ry="4" fill="rgba(42,27,61,0.18)" />
      <path
        d="M14 50 Q14 22 40 22 Q66 22 66 50 Q66 66 40 66 Q14 66 14 50 Z"
        fill="currentColor"
        stroke="#2A1B3D"
        strokeWidth="3.5"
      />
      <path d="M22 38 Q26 30 32 32" stroke="#B5E5A8" strokeWidth="3.5" fill="none" strokeLinecap="round" />
      <circle cx="30" cy="48" r="5" fill="#2A1B3D" />
      <circle cx="50" cy="48" r="5" fill="#2A1B3D" />
      <circle cx="31.5" cy="46.5" r="1.6" fill="white" />
      <circle cx="51.5" cy="46.5" r="1.6" fill="white" />
      <path d="M32 58 Q40 64 48 58" stroke="#2A1B3D" strokeWidth="3" fill="none" strokeLinecap="round" />
    </svg>
  );
}
