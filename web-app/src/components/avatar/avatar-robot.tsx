interface AvatarRobotProps {
  size?: number;
}

export function AvatarRobot({ size = 64 }: AvatarRobotProps) {
  return (
    <svg viewBox="0 0 80 80" width={size} height={size}>
      <line x1="40" y1="14" x2="40" y2="22" stroke="#2A1B3D" strokeWidth="2.5" />
      <circle cx="40" cy="12" r="3" fill="#FFB627" stroke="#2A1B3D" strokeWidth="2" />
      <rect x="14" y="22" width="52" height="48" rx="12" fill="#4ECDC4" stroke="#2A1B3D" strokeWidth="3" />
      <rect x="22" y="32" width="36" height="22" rx="6" fill="#1B3A3A" stroke="#2A1B3D" strokeWidth="2.5" />
      <circle cx="32" cy="43" r="4" fill="#FFB627" />
      <circle cx="48" cy="43" r="4" fill="#FFB627" />
      <circle cx="33" cy="41.5" r="1.4" fill="white" />
      <circle cx="49" cy="41.5" r="1.4" fill="white" />
      <rect x="32" y="60" width="16" height="4" rx="2" fill="#2A1B3D" />
      <circle cx="14" cy="42" r="4" fill="#FF6B6B" stroke="#2A1B3D" strokeWidth="2.5" />
      <circle cx="66" cy="42" r="4" fill="#FF6B6B" stroke="#2A1B3D" strokeWidth="2.5" />
    </svg>
  );
}
