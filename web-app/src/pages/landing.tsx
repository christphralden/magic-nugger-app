import { useNavigate } from "react-router-dom";
import { useScrollY } from "@/hooks/use-scroll-y";
import { WizardKid } from "@/components/mascot/wizard-kid";
import { Cloud } from "@/components/decor/cloud";
import { Sparkle } from "@/components/decor/sparkle";
import { PlusToken } from "@/components/decor/plus-token";
import { Slime } from "@/components/decor/slime";
import { Coin } from "@/components/decor/coin";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { MagicNuggerHeader } from "@/components/brand/magic-nugger-header";
import { PlayIcon } from "@/components/icons/play-icon";
import { ArrowRightIcon } from "@/components/icons/arrow-right-icon";

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

function HeroSection({ scrollY }: { scrollY: number }) {
  const navigate = useNavigate();
  const py = (rate: number) => `translateY(${scrollY * rate}px)`;
  const handleNavigateRegister = () => navigate("/register");
  const handleNavigateLogin = () => navigate("/login");

  return (
    <section className="relative px-6 py-16 overflow-hidden min-h-[560px] flex items-center">
      <div
        className="absolute left-[4%] bottom-0 z-0 pointer-events-none"
        style={{ opacity: 0.85 }}
      >
        <WizardKid size={320} />
      </div>

      <div
        className="absolute top-[40px] left-[8%] animate-float-slow"
        style={{ transform: py(0.2), opacity: 0.45, filter: "blur(0.5px)" }}
      >
        <Cloud size={160} />
      </div>
      <div
        className="absolute top-[100px] right-[8%] animate-float"
        style={{ transform: py(0.15), opacity: 0.55, filter: "blur(0.5px)" }}
      >
        <Cloud size={130} />
      </div>
      <div
        className="absolute top-[200px] left-[3%] animate-float-slow"
        style={{ transform: py(0.3), opacity: 0.35 }}
      >
        <Cloud size={90} />
      </div>

      <div
        className="absolute top-[180px] left-[22%] animate-float-fast"
        style={{ transform: py(0.6), opacity: 0.85 }}
      >
        <Sparkle size={28} className="text-coral" />
      </div>
      <div
        className="absolute top-[70px] right-[28%] animate-float"
        style={{ transform: py(0.5), opacity: 0.7 }}
      >
        <Sparkle size={22} className="text-teal" />
      </div>
      <div
        className="absolute top-[340px] left-[42%] animate-float-fast"
        style={{ transform: py(0.4), opacity: 0.4 }}
      >
        <Sparkle size={18} className="text-gold" />
      </div>

      <div
        className="absolute bottom-[100px] right-[6%] animate-float"
        style={{ transform: py(-0.45), opacity: 1 }}
      >
        <PlusToken op="×" bgClass="fill-coral" size={56} />
      </div>
      <div
        className="absolute top-[300px] right-[3%] animate-float-fast"
        style={{ transform: py(0.7), opacity: 0.55 }}
      >
        <PlusToken op="−" bgClass="fill-gold" size={48} />
      </div>
      <div
        className="absolute bottom-[180px] right-[22%] animate-float-slow"
        style={{ transform: py(-0.2), opacity: 0.3 }}
      >
        <PlusToken op="÷" bgClass="fill-lavender" size={42} />
      </div>

      <div
        className="absolute bottom-[60px] right-[14%] animate-float-slow"
        style={{ transform: py(-0.3), opacity: 0.95 }}
      >
        <Coin size={48} />
      </div>

      <div className="relative z-10 max-w-xl mx-auto text-center w-full">
        <div className="flex gap-2 mb-6 justify-center flex-wrap">
          <span className="inline-flex items-center gap-1.5 bg-cream-2 border-[2.5px] border-ink rounded-full px-[14px] py-1.5 font-display font-semibold text-[14px] shadow-cartoon-sm">
            <Sparkle size={14} className="text-ink" /> ages 6–12
          </span>
          <span className="inline-flex items-center bg-teal-light border-[2.5px] border-ink rounded-full px-[14px] py-1.5 font-display font-semibold text-[14px] shadow-cartoon-sm">
            math + adventure
          </span>
        </div>

        <h1
          className="font-display font-bold text-ink leading-[0.95] tracking-[-0.015em] mb-5"
          style={{ fontSize: "clamp(42px, 6.5vw, 86px)" }}
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
                stroke="#FFB627"
                strokeWidth="6"
                strokeLinecap="round"
                fill="none"
              />
            </svg>
          </span>
        </h1>

        <p
          className="text-ink-soft font-semibold leading-relaxed mb-8 mx-auto"
          style={{ fontSize: "clamp(17px, 1.3vw, 20px)", maxWidth: 480 }}
        >
          Magic Nugger turns multiplication, addition, and word problems into a tower-defense quest. Solve to summon spells. Miss, and the slimes get closer!
        </p>

        <div className="flex gap-4 flex-wrap justify-center mb-8">
          <CartoonButton size="xl" variant="primary" className="animate-wiggle" onClick={handleNavigateRegister}>
            <PlayIcon size={26} /> Begin Adventure
          </CartoonButton>
          <CartoonButton size="lg" variant="secondary" onClick={handleNavigateLogin}>
            I have an account
          </CartoonButton>
        </div>

        <div className="flex gap-8 justify-center flex-wrap">
          <StatItem n="120+" label="quests" />
          <StatItem n="4" label="grade levels" />
          <StatItem n="100%" label="screen-time well-spent" />
        </div>
      </div>
    </section>
  );
}

function MarqueeSection({ scrollY }: { scrollY: number }) {
  return (
    <section
      className="relative overflow-hidden border-t-[3px] border-b-[3px] border-ink bg-ink"
      style={{ padding: "24px 0" }}
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
  const handleNavigateRegister = () => navigate("/register");

  return (
    <section className="relative px-10 py-20 text-center border-t-[3px] border-ink bg-cream">
      <div className="absolute left-[10%] top-[60px] animate-float-slow" style={{ transform: "rotate(-12deg)" }}>
        <Slime size={70} className="text-coral" />
      </div>
      <div className="absolute right-[12%] top-[100px] animate-float" style={{ transform: "rotate(14deg)" }}>
        <Slime size={80} className="text-lavender" />
      </div>

      <h2
        className="font-display font-bold text-ink leading-[0.95] mb-3"
        style={{ fontSize: "clamp(36px, 5vw, 64px)" }}
      >
        Ready, math wizard?
      </h2>
      <p className="text-[20px] text-ink-soft font-semibold mb-7">
        Your first quest is free. No credit card. Just brain power.
      </p>
      <CartoonButton size="xl" variant="primary" onClick={handleNavigateRegister}>
        <Sparkle size={22} className="text-white" /> Begin Adventure <ArrowRightIcon size={22} />
      </CartoonButton>
    </section>
  );
}

export function LandingPage() {
  const scrollY = useScrollY();

  return (
    <div className="min-h-screen bg-cream font-body">
      <MagicNuggerHeader />
      <HeroSection scrollY={scrollY} />
      <MarqueeSection scrollY={scrollY} />
      <CtaSection />
    </div>
  );
}
