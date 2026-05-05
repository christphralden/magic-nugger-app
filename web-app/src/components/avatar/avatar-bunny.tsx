interface AvatarBunnyProps {
  size?: number;
}

export function AvatarBunny({ size = 64 }: AvatarBunnyProps) {
  return (
    <svg viewBox="0 0 80 80" width={size} height={size}>
      <ellipse cx="28" cy="22" rx="6" ry="14" fill="white" stroke="#2A1B3D" strokeWidth="2.5" />
      <ellipse cx="52" cy="22" rx="6" ry="14" fill="white" stroke="#2A1B3D" strokeWidth="2.5" />
      <ellipse cx="28" cy="24" rx="2.5" ry="8" fill="#FF9AAA" />
      <ellipse cx="52" cy="24" rx="2.5" ry="8" fill="#FF9AAA" />
      <circle cx="40" cy="46" r="26" fill="white" stroke="#2A1B3D" strokeWidth="3" />
      <circle cx="30" cy="44" r="4" fill="#2A1B3D" />
      <circle cx="50" cy="44" r="4" fill="#2A1B3D" />
      <circle cx="31" cy="42.5" r="1.4" fill="white" />
      <circle cx="51" cy="42.5" r="1.4" fill="white" />
      <ellipse cx="22" cy="50" rx="6" ry="3.5" fill="#FF9AAA" opacity="0.7" />
      <ellipse cx="58" cy="50" rx="6" ry="3.5" fill="#FF9AAA" opacity="0.7" />
      <path d="M40 52 L37 56 L43 56 Z" fill="#FF6B6B" stroke="#2A1B3D" strokeWidth="2" strokeLinejoin="round" />
      <path d="M34 60 Q40 64 46 60" stroke="#2A1B3D" strokeWidth="2.5" fill="none" strokeLinecap="round" />
    </svg>
  );
}
