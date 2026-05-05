import { useNavigate } from "react-router-dom";
import { useScrollY } from "@/hooks/use-scroll-y";
import { WizardKid } from "@/components/mascot/wizard-kid";
import { Cloud } from "@/components/decor/cloud";
import { Sparkle } from "@/components/decor/sparkle";
import { PlusToken } from "@/components/decor/plus-token";
import { Slime } from "@/components/decor/slime";
import { Coin } from "@/components/decor/coin";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { PlayIcon } from "@/components/icons/play-icon";
import { ArrowRightIcon } from "@/components/icons/arrow-right-icon";
import { CORAL, GOLD, TEAL, INK } from "@/constants/colors";

const MARQUEE_ITEMS = [
  { text: "7 × 8 = 56", color: "text-white" },
  { text: "slime defeated!", color: "text-gold" },
  { text: "+50 nuggets", color: "text-white" },
  { text: "tower upgraded", color: "text-coral" },
  { text: "math wizard mode", color: "text-white" },
  { text: "level up!", color: "text-teal" },
  { text: "kapow!", color: "text-white" },
  { text: "12 ÷ 4 = 3", color: "text-gold" },
  { text: "critical hit", color: "text-white" },
  { text: "new spell unlocked", color: "text-coral" },
  { text: "daily streak: 7", color: "text-white" },
  { text: "boss incoming!", color: "text-teal" },
];

interface StatItemProps {
  n: string;
  label: string;
}

function StatItem({ n, label }: StatItemProps) {
  return (
    <div>
      <div className="font-display font-bold text-[32px] text-ink leading-none">{n}</div>
      <div className="text-[13px] text-ink-soft font-bold uppercase tracking-[0.08em] mt-1">{label}</div>
    </div>
  );
}

function TopNav() {
  return (
    <div className="relative z-50 flex items-center justify-center px-10 py-[22px] bg-cream">
      <div className="flex items-center gap-3 font-display font-bold text-2xl text-ink">
        <WizardKid size={36} />
        Magic Nugger
      </div>
    </div>
  );
}

function HeroSection({ scrollY }: { scrollY: number }) {
  const navigate = useNavigate();
  const py = (rate: number) => `translateY(${scrollY * rate}px)`;

  return (
    <section className="relative px-10 py-[60px_40px_80px] overflow-hidden" style={{ padding: "60px 40px 80px" }}>
      <div
        className="absolute top-[60px] left-[8%] animate-float-slow"
        style={{ transform: py(0.2), opacity: 0.45, filter: "blur(0.5px)" }}
      >
        <Cloud size={160} />
      </div>
      <div
        className="absolute top-[120px] right-[10%] animate-float"
        style={{ transform: py(0.15), opacity: 0.55, filter: "blur(0.5px)" }}
      >
        <Cloud size={130} />
      </div>
      <div
        className="absolute top-[220px] left-[4%] animate-float-slow"
        style={{ transform: py(0.3), opacity: 0.35 }}
      >
        <Cloud size={90} />
      </div>
      <div
        className="absolute top-[200px] left-[20%] animate-float-fast"
        style={{ transform: py(0.6), opacity: 0.85 }}
      >
        <Sparkle size={28} color={CORAL} />
      </div>
      <div
        className="absolute top-[80px] right-[30%] animate-float"
        style={{ transform: py(0.5), opacity: 0.7 }}
      >
        <Sparkle size={22} color={TEAL} />
      </div>
      <div
        className="absolute top-[360px] left-[38%] animate-float-fast"
        style={{ transform: py(0.4), opacity: 0.4 }}
      >
        <Sparkle size={18} color={GOLD} />
      </div>
      <div
        className="absolute bottom-[120px] left-[6%] animate-float-slow"
        style={{ transform: py(-0.3), opacity: 0.95 }}
      >
        <PlusToken op="+" bg={TEAL} size={56} />
      </div>
      <div
        className="absolute bottom-[80px] right-[8%] animate-float"
        style={{ transform: py(-0.45), opacity: 1 }}
      >
        <PlusToken op="×" bg={CORAL} size={56} />
      </div>
      <div
        className="absolute top-[320px] right-[4%] animate-float-fast"
        style={{ transform: py(0.7), opacity: 0.55 }}
      >
        <PlusToken op="−" bg={GOLD} size={48} />
      </div>
      <div
        className="absolute bottom-[200px] left-[30%] animate-float-slow"
        style={{ transform: py(-0.2), opacity: 0.3 }}
      >
        <PlusToken op="÷" bg="#A78BFA" size={42} />
      </div>

      <div
        className="relative grid gap-12 items-center max-w-[1200px] mx-auto"
        style={{ gridTemplateColumns: "1.1fr 1fr" }}
      >
        <div>
          <div className="flex gap-2 mb-5">
            <span className="inline-flex items-center gap-1.5 bg-cream-2 border-[2.5px] border-ink rounded-full px-[14px] py-1.5 font-display font-semibold text-[14px] shadow-cartoon-sm">
              <Sparkle size={14} color={INK} /> ages 6–12
            </span>
            <span className="inline-flex items-center bg-[#A0E7E5] border-[2.5px] border-ink rounded-full px-[14px] py-1.5 font-display font-semibold text-[14px] shadow-cartoon-sm">
              math + adventure
            </span>
          </div>

          <h1
            className="font-display font-bold text-ink leading-[0.95] tracking-[-0.015em] mb-[18px]"
            style={{ fontSize: "clamp(48px, 7vw, 92px)" }}
          >
            Defend the kingdom
            <br />
            <span className="text-coral inline-block relative">
              with math!
              <svg
                viewBox="0 0 200 14"
                className="absolute left-0 w-full"
                style={{ bottom: -6, height: 14 }}
              >
                <path
                  d="M2 8 Q60 -2 120 6 T 198 4"
                  stroke={GOLD}
                  strokeWidth="6"
                  strokeLinecap="round"
                  fill="none"
                />
              </svg>
            </span>
          </h1>

          <p
            className="text-ink-soft font-semibold leading-relaxed mb-8"
            style={{ fontSize: "clamp(18px, 1.4vw, 22px)", maxWidth: 560 }}
          >
            Magic Nugger turns multiplication, addition, and word problems into a tower-defense quest. Solve to summon
            spells. Miss, and the slimes get closer!
          </p>

          <div className="flex gap-4 flex-wrap">
            <CartoonButton size="xl" variant="primary" className="animate-wiggle" onClick={() => navigate("/register")}>
              <PlayIcon size={26} /> Begin Adventure
            </CartoonButton>
            <CartoonButton size="lg" variant="secondary" onClick={() => navigate("/login")}>
              I have an account
            </CartoonButton>
          </div>

          <div className="flex gap-6 mt-8 flex-wrap">
            <StatItem n="120+" label="quests" />
            <StatItem n="4" label="grade levels" />
            <StatItem n="100%" label="screen-time well-spent" />
          </div>
        </div>

        <div className="relative flex justify-center items-center min-h-[480px]">
          <div
            className="absolute w-[380px] h-[380px] rounded-full"
            style={{ background: "radial-gradient(circle, #FFE9B0 0%, transparent 70%)" }}
          />
          <svg
            viewBox="0 0 100 100"
            width={120}
            height={120}
            className="absolute top-[30px] right-[30px] animate-float-slow"
          >
            <circle cx="50" cy="50" r="22" fill={GOLD} stroke={INK} strokeWidth="3" />
            <g stroke={INK} strokeWidth="3" strokeLinecap="round">
              <line x1="50" y1="14" x2="50" y2="22" />
              <line x1="50" y1="78" x2="50" y2="86" />
              <line x1="14" y1="50" x2="22" y2="50" />
              <line x1="78" y1="50" x2="86" y2="50" />
              <line x1="22" y1="22" x2="28" y2="28" />
              <line x1="72" y1="72" x2="78" y2="78" />
              <line x1="78" y1="22" x2="72" y2="28" />
              <line x1="22" y1="78" x2="28" y2="72" />
            </g>
          </svg>

          <div className="animate-pop-in relative z-[2]">
            <WizardKid size={360} />
          </div>

          <div
            className="animate-float absolute top-[80px] left-0"
            style={{ transform: "rotate(-6deg)" }}
          >
            <div className="bg-white border-[3px] border-ink rounded-cartoon-md shadow-[0_6px_0_0_#2A1B3D] px-5 py-[14px] font-display font-bold text-[28px] text-ink flex items-center gap-3">
              <span className="text-coral">7 × 6</span> = ?
            </div>
          </div>

          <div className="animate-float-fast absolute bottom-[30px] left-[20px]">
            <Slime size={90} />
          </div>
          <div className="animate-float absolute bottom-[60px] right-[20px]" style={{ transform: "rotate(8deg)" }}>
            <Coin size={48} />
          </div>
        </div>
      </div>
    </section>
  );
}

function MarqueeSection({ scrollY }: { scrollY: number }) {
  return (
    <section
      className="relative overflow-hidden border-t-[3px] border-b-[3px] border-ink"
      style={{ background: INK, padding: "24px 0" }}
    >
      <div
        className="flex gap-12 items-center whitespace-nowrap font-display font-bold text-[22px]"
        style={{
          transform: `translateX(${-scrollY * 0.6}px)`,
          willChange: "transform",
        }}
      >
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="flex gap-12 items-center">
            {MARQUEE_ITEMS.map((item, j) => (
              <span key={j} className={item.color}>
                ✦ {item.text}
              </span>
            ))}
          </div>
        ))}
      </div>
    </section>
  );
}

function CtaSection() {
  const navigate = useNavigate();

  return (
    <section
      className="relative px-10 py-20 text-center border-t-[3px] border-ink"
      style={{ background: "#FFF4D6" }}
    >
      <div className="absolute left-[10%] top-[60px] animate-float-slow" style={{ transform: "rotate(-12deg)" }}>
        <Slime size={70} color={CORAL} />
      </div>
      <div className="absolute right-[12%] top-[100px] animate-float" style={{ transform: "rotate(14deg)" }}>
        <Slime size={80} color="#A78BFA" />
      </div>

      <h2
        className="font-display font-bold text-ink leading-[0.95] mb-3"
        style={{ fontSize: "clamp(36px, 5vw, 64px)" }}
      >
        Ready, math wizard?
      </h2>
      <p className="text-[20px] text-ink-soft font-semibold mb-7">
        The first quest is free. No credit card. Just brain power.
      </p>
      <CartoonButton size="xl" variant="primary" onClick={() => navigate("/register")}>
        <Sparkle size={22} color="white" /> Begin Adventure <ArrowRightIcon size={22} />
      </CartoonButton>
    </section>
  );
}

export function LandingPage() {
  const scrollY = useScrollY();

  return (
    <div className="min-h-screen bg-cream font-body">
      <TopNav />
      <HeroSection scrollY={scrollY} />
      <MarqueeSection scrollY={scrollY} />
      <CtaSection />
    </div>
  );
}
