interface EyeIconProps {
  size?: number;
  hidden?: boolean;
}

export function EyeIcon({ size = 22, hidden = false }: EyeIconProps) {
  return (
    <svg
      viewBox="0 0 24 24"
      width={size}
      height={size}
      fill="none"
      stroke="#2A1B3D"
      strokeWidth="2.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M2 12 C 5 6 9 4 12 4 C 15 4 19 6 22 12 C 19 18 15 20 12 20 C 9 20 5 18 2 12 Z" />
      {hidden ? (
        <line x1="3" y1="3" x2="21" y2="21" />
      ) : (
        <circle cx="12" cy="12" r="3.5" fill="#2A1B3D" />
      )}
    </svg>
  );
}
