import { type ComponentType } from "react";
import {
  RegisterProvider,
  useRegisterContext,
} from "@/contexts/register.context";
import { Input } from "@/components/ui/input";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CartoonSelect } from "@/components/ui/cartoon-select";
import { LoadingOverlay } from "@/components/ui/loading-overlay";
import { MagicNuggerHeader } from "@/components/brand/magic-nugger-header";
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
import { AVATARS, type AvatarId } from "@/constants/avatars";
import { GRADES } from "@/constants/grades";
import { CloudPixel } from "@/components/decor/cloud-pixel";

const AVATAR_COMPONENTS: Record<AvatarId, ComponentType<{ size?: number }>> = {
  fox: AvatarFox,
  dragon: AvatarDragon,
  owl: AvatarOwl,
  bunny: AvatarBunny,
  robot: AvatarRobot,
};

const INPUT_CLASS =
  "bg-paper border-[3px] border-ink rounded-cartoon-md px-[18px] py-4 text-[17px] text-ink font-semibold h-auto placeholder:text-placeholder placeholder:font-medium focus-visible:ring-0 focus-visible:ring-offset-0 focus:bg-white focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]";

const LABEL_CLASS =
  "font-display font-semibold text-ink text-[15px] tracking-wide";

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
              background: step <= currentStep ? "#FFB627" : "#FFE9B0",
            }}
          />
        );
      })}
    </div>
  );
}

function InfoStep() {
  const {
    form,
    showPassword,
    handleInfoNext,
    handleTogglePassword,
    handleNavigateLogin,
  } = useRegisterContext();

  return (
    <>
      <CartoonButton variant="secondary" className="w-full mb-5" type="button">
        <GoogleIcon /> Sign up with Google
      </CartoonButton>

      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(handleInfoNext)}
          className="text-left"
        >
          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem className="mb-4">
                <FormLabel className={LABEL_CLASS}>Wizard name</FormLabel>
                <FormControl>
                  <Input
                    placeholder="merlin_the_brave"
                    className={INPUT_CLASS}
                    {...field}
                  />
                </FormControl>
                <FormMessage className="text-coral text-[13px] font-semibold" />
              </FormItem>
            )}
          />

          <div
            className="grid gap-3 mb-4"
            style={{ gridTemplateColumns: "1fr 1.4fr", alignItems: "end" }}
          >
            <FormField
              control={form.control}
              name="age"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className={LABEL_CLASS}>Age</FormLabel>
                  <FormControl>
                    <Input
                      min="6"
                      max="14"
                      placeholder="9"
                      className={INPUT_CLASS}
                      {...field}
                    />
                  </FormControl>
                  <FormMessage className="text-coral text-[13px] font-semibold" />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="grade"
              render={({ field }) => (
                <FormItem>
                  <CartoonSelect
                    label="Grade"
                    options={GRADES}
                    value={field.value}
                    onValueChange={field.onChange}
                  />
                  <FormMessage className="text-coral text-[13px] font-semibold" />
                </FormItem>
              )}
            />
          </div>

          <FormField
            control={form.control}
            name="parentEmail"
            render={({ field }) => (
              <FormItem className="mb-4">
                <FormLabel className={LABEL_CLASS}>
                  Parent&apos;s email
                </FormLabel>
                <FormControl>
                  <Input
                    type="email"
                    placeholder="grownup@home.com"
                    className={INPUT_CLASS}
                    {...field}
                  />
                </FormControl>
                <p className="text-[12px] text-ink-soft font-semibold mt-1.5 mx-0.5">
                  We&apos;ll ask them to confirm — for safety.
                </p>
                <FormMessage className="text-coral text-[13px] font-semibold" />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem className="mb-[22px]">
                <FormLabel className={LABEL_CLASS}>Secret password</FormLabel>
                <FormControl>
                  <div className="relative">
                    <Input
                      type={showPassword ? "text" : "password"}
                      placeholder="at least 6 magic letters"
                      className={`${INPUT_CLASS} pr-12`}
                      {...field}
                    />
                    <button
                      type="button"
                      onClick={handleTogglePassword}
                      className="absolute right-3 top-1/2 -translate-y-1/2 p-1.5"
                    >
                      <EyeIcon size={22} hidden={!showPassword} />
                    </button>
                  </div>
                </FormControl>
                <FormMessage className="text-coral text-[13px] font-semibold" />
              </FormItem>
            )}
          />

          <CartoonButton type="submit" variant="primary" className="w-full">
            Next: pick your wizard <ArrowRightIcon size={20} />
          </CartoonButton>
        </form>
      </Form>

      <p className="mt-[22px] text-[15px] text-ink-soft font-semibold">
        Already a wizard?{" "}
        <button
          className="text-coral font-extrabold underline decoration-[3px] underline-offset-4 text-[15px]"
          onClick={handleNavigateLogin}
        >
          Sign in
        </button>
      </p>
    </>
  );
}

function AvatarStep() {
  const { selectedAvatar, handleSelectAvatar, handleBack, handleAvatarSubmit } =
    useRegisterContext();

  const selected = AVATARS.find((a) => a.id === selectedAvatar)!;
  const SelectedComp = AVATAR_COMPONENTS[selected.id];

  return (
    <form onSubmit={handleAvatarSubmit}>
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
              onClick={() => handleSelectAvatar(a.id)}
            >
              <AvatarComp size={50} />
            </AvatarPickButton>
          );
        })}
      </div>

      <div className="bg-cream-2 border-[3px] border-ink rounded-cartoon-md p-[14px] mb-5 flex items-center gap-3 text-left">
        <Sparkle size={26} className="text-gold" />
        <div>
          <div className="font-display font-bold text-[15px] text-ink">
            Your first quest is free!
          </div>
          <div className="text-[12px] text-ink-soft font-semibold">
            Defend the village. Solve 5 equations.
          </div>
        </div>
      </div>

      <div className="flex gap-3">
        <CartoonButton
          type="button"
          variant="secondary"
          onClick={handleBack}
          className="flex-shrink-0"
        >
          Back
        </CartoonButton>
        <CartoonButton type="submit" variant="primary" className="flex-1">
          <Sparkle size={20} className="text-white" /> Begin Adventure{" "}
          <ArrowRightIcon size={20} />
        </CartoonButton>
      </div>
    </form>
  );
}

function RegisterHeader() {
  const { step } = useRegisterContext();
  return (
    <>
      <h1 className="font-display font-bold text-ink text-[38px] leading-[0.95] mb-2">
        {step === 1 ? "Start your quest" : "Pick your wizard"}
      </h1>
      <p className="text-[15px] text-ink-soft font-semibold mb-6">
        {step === 1
          ? "A few quick questions and you're in."
          : "Your hero awaits — choose wisely!"}
      </p>
    </>
  );
}

function RegisterCard() {
  const { step, loading } = useRegisterContext();
  return (
    <div className="min-h-screen bg-cream font-body flex flex-col overflow-hidden">
      <MagicNuggerHeader />

      <div className="flex-1 relative flex items-center justify-center px-6 py-10">
        <div className="absolute top-6 left-[8%] animate-float-slow">
          <CloudPixel variant="1" className="w-[186px]" />
        </div>
        <div className="absolute top-14 right-[10%] animate-float">
          <Sparkle size={28} className="text-gold" />
        </div>
        <div className="absolute bottom-[60px] left-[12%] animate-float-fast">
          <Sparkle size={24} className="text-teal" />
        </div>
        <div className="absolute bottom-16 right-[6%] animate-float-slow">
          <Coin size={48} />
        </div>

        <div className="animate-pop-in w-full max-w-[580px] bg-white border-[3px] border-ink rounded-xl shadow-cartoon-lg px-10 py-10 text-center">
          <RegisterHeader />
          <StepDots currentStep={step} totalSteps={2} />
          {step === 1 && <InfoStep />}
          {step === 2 && <AvatarStep />}
        </div>
      </div>

      {loading && <LoadingOverlay text="Summoning your wizard..." />}
    </div>
  );
}

export function RegisterPage() {
  return (
    <RegisterProvider>
      <RegisterCard />
    </RegisterProvider>
  );
}
