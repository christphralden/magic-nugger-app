function SmileySVG() {
  return (
    <svg viewBox="0 0 44 44" width={38} height={38} xmlns="http://www.w3.org/2000/svg">
      <circle cx="22" cy="22" r="19" fill="#FFB627" stroke="#2A1B3D" strokeWidth="3" />
      <ellipse cx="14" cy="20" rx="3.5" ry="2.5" fill="#FF9AAA" opacity="0.75" />
      <ellipse cx="30" cy="20" rx="3.5" ry="2.5" fill="#FF9AAA" opacity="0.75" />
      <circle cx="16" cy="17" r="3" fill="#2A1B3D" />
      <circle cx="28" cy="17" r="3" fill="#2A1B3D" />
      <circle cx="17.2" cy="15.8" r="1" fill="white" />
      <circle cx="29.2" cy="15.8" r="1" fill="white" />
      <path
        d="M14 27 Q22 34 30 27"
        stroke="#2A1B3D"
        strokeWidth="2.8"
        fill="none"
        strokeLinecap="round"
      />
    </svg>
  );
}

export function MagicNuggerHeader() {
  return (
    <div className="w-full flex items-center justify-center gap-3 py-[22px] bg-cream">
      <SmileySVG />
      <span className="font-display font-bold text-2xl text-ink">Magic Nugger</span>
    </div>
  );
}
