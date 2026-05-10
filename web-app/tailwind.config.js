/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        cream: "#FFF4D6",
        "cream-2": "#FFE9B0",
        gold: "#FFB627",
        "gold-deep": "#E89500",
        coral: "#FF6B6B",
        "coral-deep": "#E04848",
        teal: "#4ECDC4",
        "teal-deep": "#2BA89E",
        "teal-light": "#A0E7E5",
        ink: "#2A1B3D",
        "ink-soft": "#4A3A5C",
        paper: "#FFFBEF",
        lavender: "#A78BFA",
        placeholder: "#9A8AAB",
        green: "#7CC576",
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      fontFamily: {
        display: ["Fredoka", "sans-serif"],
        body: ["Nunito", "system-ui", "sans-serif"],
      },
      boxShadow: {
        cartoon: "0 6px 0 0 #2A1B3D, 0 12px 24px -4px rgba(42,27,61,0.18)",
        "cartoon-lg": "0 8px 0 0 #2A1B3D, 0 16px 32px -8px rgba(42,27,61,0.18)",
        "cartoon-sm": "0 3px 0 0 #2A1B3D",
        "avatar-selected": "0 0 0 4px #FFB627, 0 6px 0 0 #2A1B3D",
      },
      keyframes: {
        float: {
          "0%, 100%": { transform: "translateY(0) rotate(var(--rot, 0deg))" },
          "50%": { transform: "translateY(-12px) rotate(var(--rot, 0deg))" },
        },
        wiggle: {
          "0%, 100%": { transform: "rotate(-2deg)" },
          "50%": { transform: "rotate(2deg)" },
        },
        "pop-in": {
          "0%": { transform: "scale(0.6)", opacity: "0" },
          "60%": { transform: "scale(1.08)", opacity: "1" },
          "100%": { transform: "scale(1)", opacity: "1" },
        },
        "spin-slow": {
          from: { transform: "rotate(0deg)" },
          to: { transform: "rotate(360deg)" },
        },
        nudge: {
          "0%": { transform: "rotate(0deg)" },
          "100%": { transform: "rotate(3deg)" },
        },
      },
      animation: {
        float: "float 4s ease-in-out infinite",
        "float-slow": "float 6s ease-in-out infinite",
        "float-fast": "float 3s ease-in-out infinite",
        wiggle: "wiggle 2.6s ease-in-out infinite",
        "pop-in": "pop-in 480ms cubic-bezier(0.34, 1.56, 0.64, 1) both",
        "spin-slow": "spin-slow 0.9s linear infinite",
        nudge: "nudge 0.1s ease-out forwards",
      },
    },
  },
  plugins: [],
};
