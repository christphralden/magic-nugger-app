interface AvatarFoxProps {
  size?: number;
}

export function AvatarFox({ size = 64 }: AvatarFoxProps) {
  return (
    <svg viewBox="0 0 80 80" width={size} height={size}>
      <circle cx="40" cy="44" r="28" fill="#FF9A4D" stroke="#2A1B3D" strokeWidth="3" />
      <path d="M14 28 L22 18 L26 36 Z" fill="#FF9A4D" stroke="#2A1B3D" strokeWidth="3" strokeLinejoin="round" />
      <path d="M66 28 L58 18 L54 36 Z" fill="#FF9A4D" stroke="#2A1B3D" strokeWidth="3" strokeLinejoin="round" />
      <path d="M40 50 Q30 56 26 52" fill="white" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
      <path d="M40 50 Q50 56 54 52" fill="white" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
      <circle cx="30" cy="42" r="4" fill="#2A1B3D" />
      <circle cx="50" cy="42" r="4" fill="#2A1B3D" />
      <circle cx="31" cy="40.5" r="1.4" fill="white" />
      <circle cx="51" cy="40.5" r="1.4" fill="white" />
      <ellipse cx="40" cy="55" rx="3" ry="2.2" fill="#2A1B3D" />
      <path d="M37 58 Q40 62 43 58" stroke="#2A1B3D" strokeWidth="2.5" fill="none" strokeLinecap="round" />
    </svg>
  );
}
