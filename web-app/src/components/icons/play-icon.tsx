interface PlayIconProps {
  size?: number;
}

export function PlayIcon({ size = 22 }: PlayIconProps) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size}>
      <path d="M7 4 L7 20 L20 12 Z" fill="currentColor" stroke="#2A1B3D" strokeWidth="2" strokeLinejoin="round" />
    </svg>
  );
}
