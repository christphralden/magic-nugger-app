interface AvatarDragonProps {
  size?: number;
}

export function AvatarDragon({ size = 64 }: AvatarDragonProps) {
  return (
    <svg viewBox="0 0 80 80" width={size} height={size}>
      <circle cx="40" cy="44" r="28" fill="#7CC576" stroke="#2A1B3D" strokeWidth="3" />
      <path d="M22 22 L28 30 L20 30 Z" fill="#7CC576" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
      <path d="M40 18 L46 26 L34 26 Z" fill="#7CC576" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
      <path d="M58 22 L60 30 L52 30 Z" fill="#7CC576" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
      <ellipse cx="40" cy="50" rx="14" ry="10" fill="#B5E5A8" stroke="#2A1B3D" strokeWidth="2" />
      <circle cx="30" cy="42" r="4" fill="#2A1B3D" />
      <circle cx="50" cy="42" r="4" fill="#2A1B3D" />
      <circle cx="31" cy="40.5" r="1.4" fill="white" />
      <circle cx="51" cy="40.5" r="1.4" fill="white" />
      <circle cx="34" cy="50" r="1.5" fill="#2A1B3D" />
      <circle cx="46" cy="50" r="1.5" fill="#2A1B3D" />
      <path d="M34 56 Q40 60 46 56" stroke="#2A1B3D" strokeWidth="2.5" fill="none" strokeLinecap="round" />
    </svg>
  );
}
