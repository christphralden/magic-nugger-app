interface AvatarOwlProps {
  size?: number;
}

export function AvatarOwl({ size = 64 }: AvatarOwlProps) {
  return (
    <svg viewBox="0 0 80 80" width={size} height={size}>
      <path
        d="M40 12 Q18 12 18 38 Q18 64 40 68 Q62 64 62 38 Q62 12 40 12 Z"
        fill="#A78BFA"
        stroke="#2A1B3D"
        strokeWidth="3"
        strokeLinejoin="round"
      />
      <path d="M22 18 L28 14 L30 22 Z" fill="#A78BFA" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
      <path d="M58 18 L52 14 L50 22 Z" fill="#A78BFA" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
      <circle cx="30" cy="36" r="9" fill="white" stroke="#2A1B3D" strokeWidth="2.5" />
      <circle cx="50" cy="36" r="9" fill="white" stroke="#2A1B3D" strokeWidth="2.5" />
      <circle cx="30" cy="36" r="4" fill="#2A1B3D" />
      <circle cx="50" cy="36" r="4" fill="#2A1B3D" />
      <circle cx="31" cy="34.5" r="1.4" fill="white" />
      <circle cx="51" cy="34.5" r="1.4" fill="white" />
      <path d="M36 46 L40 52 L44 46 Z" fill="#FFB627" stroke="#2A1B3D" strokeWidth="2.5" strokeLinejoin="round" />
    </svg>
  );
}
