import { useState, FormEvent, ComponentType } from "react";
import { useNavigate } from "react-router-dom";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CartoonInput } from "@/components/ui/cartoon-input";
import { CartoonSelect } from "@/components/ui/cartoon-select";
import { LoadingOverlay } from "@/components/ui/loading-overlay";
import { AvatarPickButton } from "@/components/avatar/avatar-pick-button";
import { AvatarFox } from "@/components/avatar/avatar-fox";
import { AvatarDragon } from "@/components/avatar/avatar-dragon";
import { AvatarOwl } from "@/components/avatar/avatar-owl";
import { AvatarBunny } from "@/components/avatar/avatar-bunny";
import { AvatarRobot } from "@/components/avatar/avatar-robot";
import { GoogleIcon } from "@/components/icons/google-icon";
import { EyeIcon } from "@/components/icons/eye-icon";
import { ArrowRightIcon } from "@/components/icons/arrow-right-icon";
import { Sparkle } from "@/components/decor/sparkle";
import { Cloud } from "@/components/decor/cloud";
import { Coin } from "@/components/decor/coin";
import { AVATARS, AvatarId } from "@/constants/avatars";
import { GOLD, TEAL } from "@/constants/colors";

const GRADES = [
  { value: "1st grade", label: "1st grade" },
  { value: "2nd grade", label: "2nd grade" },
  { value: "3rd grade", label: "3rd grade" },
  { value: "4th grade", label: "4th grade" },
  { value: "5th grade", label: "5th grade" },
  { value: "6th grade", label: "6th grade" },
];

const AVATAR_COMPONENTS: Record<AvatarId, ComponentType<{ size?: number }>> = {
  fox: AvatarFox,
  dragon: AvatarDragon,
  owl: AvatarOwl,
  bunny: AvatarBunny,
  robot: AvatarRobot,
};

const LOADING_DURATION_MS = 2400;

interface StepDotsProps {
  currentStep: number;
  totalSteps: number;
}

function StepDots({ currentStep, totalSteps }: StepDotsProps) {
  return (
    <div className="flex gap-2 justify-center mb-7">
      {Array.from({ length: totalSteps }).map((_, i) => {
        const step = i + 1;
        const active = step === currentStep;
        return (
          <div
            key={step}
            className="h-3 border-[3px] border-ink rounded-full transition-all duration-200"
            style={{
              width: active ? 36 : 14,
              background: step <= currentStep ? GOLD : "#FFE9B0",
            }}
          />
        );
      })}
    </div>
  );
}

interface InfoStepProps {
  name: string;
  age: string;
  grade: string;
  parentEmail: string;
  password: string;
  showPassword: boolean;
  onName: (v: string) => void;
  onAge: (v: string) => void;
  onGrade: (v: string) => void;
  onParentEmail: (v: string) => void;
  onPassword: (v: string) => void;
  onTogglePassword: () => void;
  onNext: (e: FormEvent<HTMLFormElement>) => void;
  onGoLogin: () => void;
}

function InfoStep({
  name,
  age,
  grade,
  parentEmail,
  password,
  showPassword,
  onName,
  onAge,
  onGrade,
  onParentEmail,
  onPassword,
  onTogglePassword,
  onNext,
  onGoLogin,
}: InfoStepProps) {
  return (
    <>
      <CartoonButton variant="secondary" className="w-full mb-5" type="button">
        <GoogleIcon /> Sign up with Google
      </CartoonButton>

      <form onSubmit={onNext} className="text-left">
        <div className="mb-4">
          <CartoonInput
            label="Wizard name"
            placeholder="merlin_the_brave"
            value={name}
            onChange={(e) => onName(e.target.value)}
            required
          />
        </div>

        <div className="grid gap-3 mb-4" style={{ gridTemplateColumns: "1fr 1.4fr", alignItems: "end" }}>
          <CartoonInput
            label="Age"
            type="number"
            min="6"
            max="14"
            placeholder="9"
            value={age}
            onChange={(e) => onAge(e.target.value)}
            required
          />
          <CartoonSelect
            label="Grade"
            options={GRADES}
            value={grade}
            onChange={(e) => onGrade(e.target.value)}
          />
        </div>

        <div className="mb-4">
          <CartoonInput
            label="Parent's email"
            type="email"
            placeholder="grownup@home.com"
            value={parentEmail}
            onChange={(e) => onParentEmail(e.target.value)}
            required
          />
          <p className="text-[12px] text-ink-soft font-semibold mt-1.5 mx-0.5">
            We'll ask them to confirm — for safety.
          </p>
        </div>

        <div className="mb-[22px]">
          <CartoonInput
            label="Secret password"
            type={showPassword ? "text" : "password"}
            placeholder="at least 6 magic letters"
            value={password}
            onChange={(e) => onPassword(e.target.value)}
            required
            minLength={6}
            rightSlot={
              <button type="button" onClick={onTogglePassword} className="p-1.5">
                <EyeIcon size={22} hidden={!showPassword} />
              </button>
            }
          />
        </div>

        <CartoonButton type="submit" variant="primary" className="w-full">
          Next: pick your wizard <ArrowRightIcon size={20} />
        </CartoonButton>
      </form>

      <p className="mt-[22px] text-[15px] text-ink-soft font-semibold">
        Already a wizard?{" "}
        <button
          className="text-coral font-extrabold underline decoration-[3px] underline-offset-4 text-[15px]"
          onClick={onGoLogin}
        >
          Sign in
        </button>
      </p>
    </>
  );
}

interface AvatarStepProps {
  selectedAvatar: AvatarId;
  onSelectAvatar: (id: AvatarId) => void;
  onBack: () => void;
  onSubmit: (e: FormEvent<HTMLFormElement>) => void;
}

function AvatarStep({ selectedAvatar, onSelectAvatar, onBack, onSubmit }: AvatarStepProps) {
  const selected = AVATARS.find((a) => a.id === selectedAvatar)!;
  const SelectedComp = AVATAR_COMPONENTS[selected.id];

  return (
    <form onSubmit={onSubmit}>
      <div className="flex justify-center mb-5">
        <div
          key={selectedAvatar}
          className="animate-pop-in w-[140px] h-[140px] rounded-full border-4 border-ink flex items-center justify-center shadow-[0_6px_0_0_#2A1B3D]"
          style={{ background: selected.bg }}
        >
          <SelectedComp size={100} />
        </div>
      </div>

      <div className="grid grid-cols-5 gap-3 mb-6 max-w-[420px] mx-auto">
        {AVATARS.map((a) => {
          const AvatarComp = AVATAR_COMPONENTS[a.id];
          return (
            <AvatarPickButton
              key={a.id}
              bg={a.bg}
              selected={selectedAvatar === a.id}
              onClick={() => onSelectAvatar(a.id)}
            >
              <AvatarComp size={50} />
            </AvatarPickButton>
          );
        })}
      </div>

      <div className="bg-cream-2 border-[3px] border-ink rounded-cartoon-md p-[14px] mb-5 flex items-center gap-3 text-left">
        <Sparkle size={26} color={GOLD} />
        <div>
          <div className="font-display font-bold text-[15px] text-ink">Your first quest is free!</div>
          <div className="text-[12px] text-ink-soft font-semibold">Defend the village. Solve 5 equations.</div>
        </div>
      </div>

      <div className="flex gap-3">
        <CartoonButton type="button" variant="secondary" onClick={onBack} className="flex-shrink-0">
          Back
        </CartoonButton>
        <CartoonButton type="submit" variant="primary" className="flex-1">
          <Sparkle size={20} color="white" /> Begin Adventure <ArrowRightIcon size={20} />
        </CartoonButton>
      </div>
    </form>
  );
}

export function RegisterPage() {
  const navigate = useNavigate();
  const [step, setStep] = useState<1 | 2>(1);
  const [name, setName] = useState("");
  const [age, setAge] = useState("");
  const [grade, setGrade] = useState("3rd grade");
  const [parentEmail, setParentEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [avatar, setAvatar] = useState<AvatarId>("fox");
  const [loading, setLoading] = useState(false);

  const handleInfoNext = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setStep(2);
  };

  const handleAvatarSubmit = (e: FormEvent<HTMLFormElement>) => {
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
        <Sparkle size={24} color={TEAL} />
      </div>
      <div className="absolute bottom-20 right-[6%] animate-float-slow">
        <Coin size={48} />
      </div>

      <div className="animate-pop-in w-full max-w-[480px] bg-white border-[3px] border-ink rounded-cartoon-lg shadow-cartoon-lg px-10 py-10 text-center">
        <h1 className="font-display font-bold text-ink text-[38px] leading-[0.95] mb-2">
          {step === 1 ? "Start your quest" : "Pick your wizard"}
        </h1>
        <p className="text-[15px] text-ink-soft font-semibold mb-6">
          {step === 1 ? "A few quick questions and you're in." : "Your hero awaits — choose wisely!"}
        </p>

        <StepDots currentStep={step} totalSteps={2} />

        {step === 1 && (
          <InfoStep
            name={name}
            age={age}
            grade={grade}
            parentEmail={parentEmail}
            password={password}
            showPassword={showPassword}
            onName={setName}
            onAge={setAge}
            onGrade={setGrade}
            onParentEmail={setParentEmail}
            onPassword={setPassword}
            onTogglePassword={() => setShowPassword((s) => !s)}
            onNext={handleInfoNext}
            onGoLogin={() => navigate("/login")}
          />
        )}

        {step === 2 && (
          <AvatarStep
            selectedAvatar={avatar}
            onSelectAvatar={setAvatar}
            onBack={() => setStep(1)}
            onSubmit={handleAvatarSubmit}
          />
        )}
      </div>

      {loading && <LoadingOverlay text="Summoning your wizard..." />}
    </div>
  );
}
