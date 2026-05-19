const glyphs = [
  {
    ch: "+",
    size: 72,
    color: "#FFB627",
    top: "60px",
    left: "70px",
    opacity: 0.55,
    rot: "-12deg",
    animation: "float-slow",
  },
  {
    ch: "×",
    size: 64,
    color: "#4ECDC4",
    top: "120px",
    right: "110px",
    opacity: 0.55,
    rot: "8deg",
    animation: "float",
  },
  {
    ch: "÷",
    size: 56,
    color: "#FF6B6B",
    bottom: "110px",
    left: "130px",
    opacity: 0.5,
    rot: "-6deg",
    animation: "float-fast",
  },
  {
    ch: "−",
    size: 68,
    color: "#E89500",
    bottom: "180px",
    right: "80px",
    opacity: 0.45,
    rot: "14deg",
    animation: "float-slow",
  },
  {
    ch: "=",
    size: 48,
    color: "#4A3A5C",
    top: "220px",
    left: "46%",
    opacity: 0.35,
    rot: "-4deg",
    animation: "float",
  },
  {
    ch: "π",
    size: 52,
    color: "#2BA89E",
    bottom: "70px",
    left: "52%",
    opacity: 0.4,
    rot: "10deg",
    animation: "float-fast",
  },
] as const;

export function GlyphBackground() {
  return (
    <div
      aria-hidden
      className="absolute inset-0 pointer-events-none overflow-hidden"
    >
      {glyphs.map((g, i) => (
        <span
          key={i}
          className={`absolute animate-${g.animation} select-none leading-none`}
          style={{
            top: "top" in g ? g.top : undefined,
            bottom: "bottom" in g ? g.bottom : undefined,
            left: "left" in g ? g.left : undefined,
            right: "right" in g ? g.right : undefined,
            opacity: g.opacity,
            fontSize: g.size,
            color: g.color,
            fontFamily: "var(--font-display)",
            fontWeight: 700,
            WebkitTextStroke: "3px #2A1B3D",
            textShadow: "0 4px 0 #2A1B3D",
            transform: `rotate(${g.rot})`,
          }}
        >
          {g.ch}
        </span>
      ))}
    </div>
  );
}
