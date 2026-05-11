interface AlertIconProps {
  size?: number;
  className?: string;
}

export function AlertWarningIcon({ size = 24, className }: AlertIconProps) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size} className={className}>
      <path
        d="M13 4.5 L21.5 20.5 Q22.5 22.5, 20 22.5 L4 22.5 Q1.5 22.5, 2.5 20.5 L11 4.5 Q12 2.5, 13 4.5 Z"
        fill="currentColor"
      />
      <path
        d="M13.1 5.2 L19.9 18.8 Q21 21, 18.5 21 L5.5 21 Q3 21, 4.1 18.8 L10.9 5.2 Q12 3, 13.1 5.2 Z"
        fill="currentColor"
        stroke="#2A1B3D"
        strokeWidth="1.6"
        strokeLinejoin="round"
      />
      <path d="M12 9 L12 14" stroke="#2A1B3D" strokeWidth="2.5" strokeLinecap="round" />
      <circle cx="12" cy="17.5" r="1.2" fill="#2A1B3D" />
    </svg>
  );
}

export function AlertErrorIcon({ size = 24, className }: AlertIconProps) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size} className={className}>
      <ellipse cx="12" cy="12.8" rx="10.8" ry="11.2" fill="currentColor" />
      <circle cx="12" cy="12" r="10" fill="currentColor" stroke="#2A1B3D" strokeWidth="1.6" />
      <path
        d="M8 8 L16 16 M16 8 L8 16"
        stroke="#2A1B3D"
        strokeWidth="2.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

