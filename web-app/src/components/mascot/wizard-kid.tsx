interface WizardKidProps {
  size?: number;
}

export function WizardKid({ size = 280 }: WizardKidProps) {
  return (
    <svg
      viewBox="0 0 280 320"
      width={size}
      height={size * (320 / 280)}
      xmlns="http://www.w3.org/2000/svg"
      style={{ display: "block" }}
    >
      <ellipse cx="140" cy="305" rx="80" ry="10" fill="rgba(42,27,61,0.18)" />

      <path
        d="M70 220 Q70 200 90 195 L190 195 Q210 200 210 220 L222 295 Q140 305 58 295 Z"
        fill="#6B4FB8"
        stroke="#2A1B3D"
        strokeWidth="5"
        strokeLinejoin="round"
      />
      <g fill="#FFB627">
        <path d="M100 240 l4 9 l9 1 l-7 6 l2 9 l-8 -5 l-8 5 l2 -9 l-7 -6 l9 -1 z" />
        <path d="M170 260 l3 7 l7 1 l-5 5 l1 7 l-6 -4 l-6 4 l1 -7 l-5 -5 l7 -1 z" />
      </g>

      <rect x="90" y="218" width="100" height="14" fill="#FFB627" stroke="#2A1B3D" strokeWidth="4" />
      <rect x="128" y="216" width="24" height="18" fill="#E89500" stroke="#2A1B3D" strokeWidth="4" rx="3" />

      <path
        d="M75 220 Q55 240 60 270 Q72 268 80 248"
        fill="#6B4FB8"
        stroke="#2A1B3D"
        strokeWidth="5"
        strokeLinejoin="round"
      />
      <path
        d="M205 220 Q230 230 232 265 L210 268 Q200 245 200 230"
        fill="#6B4FB8"
        stroke="#2A1B3D"
        strokeWidth="5"
        strokeLinejoin="round"
      />

      <g transform="translate(228, 240) rotate(-25)">
        <rect x="-3" y="-60" width="6" height="60" fill="#2A1B3D" rx="3" />
        <path
          d="M0 -85 l8 18 l18 4 l-15 12 l4 19 l-15 -10 l-15 10 l4 -19 l-15 -12 l18 -4 z"
          fill="#FFB627"
          stroke="#2A1B3D"
          strokeWidth="4"
          strokeLinejoin="round"
        />
      </g>

      <circle cx="62" cy="268" r="11" fill="#FFD9B0" stroke="#2A1B3D" strokeWidth="4" />
      <circle cx="222" cy="262" r="11" fill="#FFD9B0" stroke="#2A1B3D" strokeWidth="4" />

      <circle cx="140" cy="150" r="58" fill="#FFD9B0" stroke="#2A1B3D" strokeWidth="5" />
      <path
        d="M105 110 Q120 88 145 92 Q170 86 180 110 Q175 100 160 102 Q150 92 135 100 Q120 95 110 110 Z"
        fill="#3A2F4D"
        stroke="#2A1B3D"
        strokeWidth="4"
        strokeLinejoin="round"
      />

      <ellipse cx="108" cy="162" rx="10" ry="7" fill="#FF9AAA" opacity="0.8" />
      <ellipse cx="172" cy="162" rx="10" ry="7" fill="#FF9AAA" opacity="0.8" />

      <circle cx="120" cy="148" r="8" fill="#2A1B3D" />
      <circle cx="160" cy="148" r="8" fill="#2A1B3D" />
      <circle cx="123" cy="145" r="2.5" fill="white" />
      <circle cx="163" cy="145" r="2.5" fill="white" />

      <path d="M122 172 Q140 188 158 172" stroke="#2A1B3D" strokeWidth="5" fill="none" strokeLinecap="round" />

      <path
        d="M85 105 L150 18 L210 110 Q150 95 85 105 Z"
        fill="#6B4FB8"
        stroke="#2A1B3D"
        strokeWidth="5"
        strokeLinejoin="round"
      />
      <path
        d="M82 100 Q150 85 215 105 L218 118 Q150 100 80 118 Z"
        fill="#FFB627"
        stroke="#2A1B3D"
        strokeWidth="5"
        strokeLinejoin="round"
      />
      <path
        d="M150 55 l5 11 l12 1 l-9 8 l3 12 l-11 -6 l-11 6 l3 -12 l-9 -8 l12 -1 z"
        fill="#FFB627"
        stroke="#2A1B3D"
        strokeWidth="3"
        strokeLinejoin="round"
      />
    </svg>
  );
}
