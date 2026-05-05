import { useState, FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CartoonInput } from "@/components/ui/cartoon-input";
import { LoadingOverlay } from "@/components/ui/loading-overlay";
import { GoogleIcon } from "@/components/icons/google-icon";
import { EyeIcon } from "@/components/icons/eye-icon";
import { PlayIcon } from "@/components/icons/play-icon";
import { ArrowRightIcon } from "@/components/icons/arrow-right-icon";
import { Cloud } from "@/components/decor/cloud";
import { Sparkle } from "@/components/decor/sparkle";
import { Coin } from "@/components/decor/coin";
import { GOLD, CORAL } from "@/constants/colors";

const LOADING_DURATION_MS = 2200;

export function LoginPage() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      navigate("/levels");
    }, LOADING_DURATION_MS);
  };

  return (
    <div className="min-h-screen bg-cream font-body relative flex items-center justify-center px-6 py-10 overflow-hidden">
      <div className="absolute top-10 left-[8%] animate-float-slow">
        <Cloud size={120} />
      </div>
      <div className="absolute top-20 right-[10%] animate-float">
        <Sparkle size={28} color={GOLD} />
      </div>
      <div className="absolute bottom-[60px] left-[12%] animate-float-fast">
        <Sparkle size={24} color={CORAL} />
      </div>
      <div className="absolute bottom-20 right-[6%] animate-float-slow">
        <Coin size={48} />
      </div>

      <div className="animate-pop-in w-full max-w-[480px] bg-white border-[3px] border-ink rounded-cartoon-lg shadow-cartoon-lg px-10 py-10 text-center">
        <h1 className="font-display font-bold text-ink text-[40px] leading-[0.95] mb-2">Welcome back!</h1>
        <p className="text-[16px] text-ink-soft font-semibold mb-7">Your towers missed you</p>

        <CartoonButton variant="secondary" className="w-full mb-5" type="button">
          <GoogleIcon /> Continue with Google
        </CartoonButton>

        <form onSubmit={handleSubmit} className="text-left">
          <div className="mb-4">
            <CartoonInput
              label="Username or email"
              placeholder="merlin_the_brave"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>

          <div className="mb-3">
            <CartoonInput
              label="Secret password"
              type={showPassword ? "text" : "password"}
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              rightSlot={
                <button type="button" onClick={() => setShowPassword((s) => !s)} className="p-1.5">
                  <EyeIcon size={22} hidden={!showPassword} />
                </button>
              }
            />
          </div>

          <div className="flex justify-between items-center mb-6">
            <button
              type="button"
              className="flex items-center gap-2.5 text-[14px] text-ink-soft cursor-pointer"
              onClick={() => setRememberMe((r) => !r)}
            >
              <span
                className={[
                  "w-[22px] h-[22px] border-[3px] border-ink rounded-[6px] bg-white flex-shrink-0 inline-flex items-center justify-center",
                  rememberMe ? "bg-gold" : "",
                ]
                  .filter(Boolean)
                  .join(" ")}
              >
                {rememberMe && (
                  <svg viewBox="0 0 16 16" width="14" height="14">
                    <path
                      d="M3 8 L7 12 L13 4"
                      stroke="#2A1B3D"
                      strokeWidth="3"
                      fill="none"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                )}
              </span>
              Keep me signed in
            </button>
            <button
              type="button"
              className="font-bold text-[14px] text-coral"
              onClick={() => {}}
            >
              Forgot password?
            </button>
          </div>

          <CartoonButton type="submit" variant="primary" className="w-full">
            <PlayIcon size={22} /> Enter the Realm <ArrowRightIcon size={20} />
          </CartoonButton>
        </form>

        <p className="mt-6 text-[15px] text-ink-soft font-semibold">
          New here?{" "}
          <button
            className="text-coral font-extrabold underline decoration-[3px] underline-offset-4 text-[15px]"
            onClick={() => navigate("/register")}
          >
            Create an account
          </button>
        </p>
      </div>

      {loading && <LoadingOverlay text="Casting your spell..." />}
    </div>
  );
}
