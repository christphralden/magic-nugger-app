import { useNavigate } from "react-router-dom";
import { useScrollY } from "@/hooks/use-scroll-y";
import { Sparkle } from "@/components/decor/sparkle";
import { PlusToken } from "@/components/decor/plus-token";
import { Coin } from "@/components/decor/coin";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { MagicNuggerHeader } from "@/components/brand/magic-nugger-header";
import { Typography } from "@/components/ui/typography";
import CountUp from "@/components/count-up";
import { FloatingText } from "@/components/floating-text";
import { CloudPixel } from "@/components/decor/cloud-pixel";
import { CartoonPill } from "@/components/ui/cartoon-pill";
import { Highlighter } from "@/components/highlighter";

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

function HeroSection({ scrollY }: { scrollY: number }) {
  const navigate = useNavigate();
  const py = (rate: number) => `translateY(${scrollY * rate}px)`;
  const handleNavigateRegister = () => navigate("/register");
  const handleNavigateLogin = () => navigate("/login");

  return (
    <section className="relative px-6 pt-8 pb-20 overflow-hidden min-h-[560px] flex items-center">
      <div
        className="absolute top-[40px] left-[8%] animate-float-slow"
        style={{ transform: py(0.2), opacity: 0.9 }}
      >
        <CloudPixel className="w-48" variant="1" />
      </div>
      <div
        className="absolute top-[100px] right-[8%] animate-float"
        style={{ transform: py(0.15), opacity: 0.9 }}
      >
        <CloudPixel className="w-[200px] rotate-[-25deg]" variant="5" />
      </div>
      <div
        className="absolute top-[300px] left-[25%] animate-float-slow"
        style={{ transform: py(0.3), opacity: 0.7, filter: "blur(2px)" }}
      >
        <CloudPixel className="w-[200px] rotate-[-15deg]" variant="6" />
      </div>

      <div
        className="absolute top-[180px] left-[22%] animate-float-fast"
        style={{ transform: py(0.6), opacity: 0.85 }}
      >
        <Sparkle size={32} className="text-coral" />
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
        <PlusToken op="×" bgClass="fill-coral" size={128} />
      </div>
      <div
        className="absolute top-[300px] right-[3%] animate-float-fast"
        style={{ transform: py(0.7), opacity: 0.55 }}
      >
        <PlusToken op="−" bgClass="fill-gold" size={86} />
      </div>
      <div
        className="absolute bottom-[180px] right-[22%] animate-float-slow"
        style={{ transform: py(-0.2), opacity: 0.3 }}
      >
        <PlusToken op="÷" bgClass="fill-lavender" size={64} />
      </div>

      <div
        className="absolute bottom-[60px] left-[14%] animate-float-slow"
        style={{ transform: py(-0.3), opacity: 0.95 }}
      >
        <Coin size={48} />
      </div>

      <div className="relative z-10 mx-auto text-center w-full max-w-[80vw] flex flex-col items-center justify-center gap-16">
        <div className="flex gap-2 justify-center flex-wrap">
          <CartoonPill className="bg-cream-2 hover:animate-nudge">
            <Sparkle size={14} className="text-ink" /> ages 6–12
          </CartoonPill>
          <CartoonPill className="bg-teal-light hover:animate-nudge">
            math + adventure
          </CartoonPill>
        </div>

        <div className="flex flex-col gap-8">
          <Typography className="select-none" variant={"heading"} as="h1">
            <FloatingText text="Defend the kingdom" offset={0} />
            <br />
            <Typography
              variant={"heading"}
              as="span"
              className="text-coral inline-block relative"
            >
              <FloatingText text="with math!" offset={19} />
              <svg
                viewBox="0 0 200 14"
                className="absolute left-0 w-full"
                style={{ bottom: -14, height: 14 }}
              >
                <path
                  d="M2 8 Q60 -2 120 6 T 198 4"
                  stroke="#FFB627"
                  strokeWidth="6"
                  strokeLinecap="round"
                  fill="none"
                />
              </svg>
            </Typography>
          </Typography>
          <Typography as="p" variant={"subheading"}>
            Build&nbsp;
            <Highlighter action="underline" color="#FF6B6B">
              confidence
            </Highlighter>
            &nbsp;through&nbsp;
            <Highlighter
              action="highlight"
              color="#A0E7E5"
              iterations={2}
              duration={600}
            >
              adventures
            </Highlighter>
            &nbsp;every day
          </Typography>
        </div>

        <div className="flex flex-row gap-6 flex-wrap justify-center items-center">
          <CartoonButton
            size="xl"
            variant="primary"
            onClick={handleNavigateRegister}
          >
            ✦ New Adventure
          </CartoonButton>
          <CartoonButton
            size="lg"
            variant="secondary"
            onClick={handleNavigateLogin}
          >
            I have an account
          </CartoonButton>
        </div>

        <div className="flex justify-evenly gap-8 flex-wrap mt-8 w-full max-w-[500px]">
          <div className="w-24">
            <Typography variant={"strong"}>
              <CountUp
                from={0}
                to={120}
                separator=","
                direction="up"
                duration={0.2}
                delay={0}
              />
              +
            </Typography>
            <Typography variant={"body"} className="capitalize">
              Quests
            </Typography>
          </div>
          <div className="w-24">
            <Typography variant={"strong"}>
              <CountUp
                from={0}
                to={6}
                separator=","
                direction="up"
                duration={1}
                delay={0.2}
              />
              +
            </Typography>
            <Typography variant={"body"} className="capitalize">
              Levels
            </Typography>
          </div>
          <div className="w-36">
            <Typography variant={"strong"}>
              +
              <CountUp
                from={0}
                to={30}
                separator=","
                direction="up"
                duration={1}
                delay={0.1}
              />
              %
            </Typography>
            <Typography variant={"body"} className="capitalize">
              faster progress
            </Typography>
          </div>
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
      <h2
        className="font-display font-bold text-ink leading-[0.95] mb-3"
        style={{ fontSize: "clamp(36px, 5vw, 64px)" }}
      >
        Ready, math wizard?
      </h2>
      <p className="text-[20px] text-ink-soft font-semibold mb-7">
        <Highlighter
          action="underline"
          color="#FF6B6B"
          strokeWidth={3}
          iterations={1}
          duration={200}
        >
          Free to play!
        </Highlighter>{" "}
        No credit card. Just brain power.
      </p>
      <CartoonButton
        size="xl"
        variant="primary"
        onClick={handleNavigateRegister}
      >
        ✦ Start learning&nbsp;
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
