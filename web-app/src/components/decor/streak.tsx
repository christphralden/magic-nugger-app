export const IconStreak = ({
  className,
  size = 18,
}: {
  className?: string;
  size?: number;
}) => (
  <svg
    className={className}
    viewBox="0 0 24 24"
    width={size}
    height={size}
    fill="currentColor"
  >
    <path d="M13.5 0.7C14.2 4.2 11 6.5 10 9c-1.2 3 0.4 5.6 2.5 5.4-0.6-1.6 0.3-3 1.5-3.8 0.3 2 2 3.2 3 5.3 1.5 3.2-0.6 7.3-5 8.1-5 0.9-9-3-8.4-7.6C4 11 8 9 9 5 9.6 2.6 11.6 1.4 13.5 0.7z" />
  </svg>
);
