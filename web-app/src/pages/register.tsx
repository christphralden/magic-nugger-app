import { type ComponentType } from "react";
import {
  RegisterProvider,
  useRegisterContext,
} from "@/contexts/register.context";
import { CartoonInput } from "@/components/ui/cartoon-input";
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
import { Coin } from "@/components/decor/coin";
import { AVATARS, type AvatarId } from "@/constants/avatars";
import { GRADES } from "@/constants/grades";
import { CloudPixel } from "@/components/decor/cloud-pixel";
import { Typography } from "@/components/ui/typography";
import { AuthPageLayout, AuthCard } from "@/components/layout/auth-layout";
import { Button } from "@/components/ui/button";

const AVATAR_COMPONENTS: Record<AvatarId, ComponentType<{ size?: number }>> = {
  fox: AvatarFox,
  dragon: AvatarDragon,
  owl: AvatarOwl,
  bunny: AvatarBunny,
  robot: AvatarRobot,
};

const FORM_LABEL_CLASS =
  "font-display font-semibold text-ink text-[15px] tracking-wide";

const FORM_ERROR_CLASS = "text-coral text-[13px] font-semibold";

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
            className={`h-3 border-[3px] border-ink rounded-full transition-all duration-200 ${
              active ? "w-9" : "w-3.5"
            } ${step <= currentStep ? "bg-gold" : "bg-cream-2"}`}
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
      <CartoonButton variant="secondary" className="w-full" type="button">
        <GoogleIcon /> Sign up with Google
      </CartoonButton>

      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(handleInfoNext)}
          className="text-left flex flex-col gap-4 mt-5"
        >
          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem>
                <FormLabel className={FORM_LABEL_CLASS}>Wizard name</FormLabel>
                <FormControl>
                  <CartoonInput placeholder="merlin_the_brave" {...field} />
                </FormControl>
                <FormMessage className={FORM_ERROR_CLASS} />
              </FormItem>
            )}
          />

          <div className="grid grid-cols-[1fr_1.4fr] gap-3 items-end">
            <FormField
              control={form.control}
              name="age"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className={FORM_LABEL_CLASS}>Age</FormLabel>
                  <FormControl>
                    <CartoonInput
                      type="number"
                      min="6"
                      max="14"
                      placeholder="9"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage className={FORM_ERROR_CLASS} />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="grade"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className={FORM_LABEL_CLASS}>Grade</FormLabel>
                  <CartoonSelect
                    options={GRADES}
                    value={field.value}
                    onValueChange={field.onChange}
                  />
                  <FormMessage className={FORM_ERROR_CLASS} />
                </FormItem>
              )}
            />
          </div>

          <FormField
            control={form.control}
            name="parentEmail"
            render={({ field }) => (
              <FormItem>
                <FormLabel className={FORM_LABEL_CLASS}>
                  Parent&apos;s email
                </FormLabel>
                <FormControl>
                  <CartoonInput
                    type="email"
                    placeholder="grownup@home.com"
                    {...field}
                  />
                </FormControl>
                <Typography
                  variant="caption"
                  className="text-[12px] text-ink-soft font-semibold mt-1.5 mx-0.5"
                >
                  We&apos;ll ask them to confirm, for safety.
                </Typography>
                <FormMessage className={FORM_ERROR_CLASS} />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <FormLabel className={FORM_LABEL_CLASS}>
                  Secret password
                </FormLabel>
                <FormControl>
                  <CartoonInput
                    type={showPassword ? "text" : "password"}
                    placeholder="at least 6 magic letters"
                    rightSlot={
                      <Button
                        variant={"ghost"}
                        onClick={handleTogglePassword}
                        className="p-1.5"
                      >
                        <EyeIcon size={22} hidden={!showPassword} />
                      </Button>
                    }
                    {...field}
                  />
                </FormControl>
                <FormMessage className={FORM_ERROR_CLASS} />
              </FormItem>
            )}
          />

          <CartoonButton type="submit" variant="primary" className="w-full">
            Next: pick your wizard <ArrowRightIcon size={20} />
          </CartoonButton>
        </form>
      </Form>

      <Typography variant="label" className="mt-6 text-ink-soft">
        Already a wizard?{" "}
        <Button
          variant={"link"}
          className="text-coral font-extrabold underline decoration-[3px] underline-offset-4 text-[15px] px-0"
          onClick={handleNavigateLogin}
        >
          <Typography variant="label">Sign in</Typography>
        </Button>
      </Typography>
    </>
  );
}

function AvatarStep() {
  const { selectedAvatar, handleSelectAvatar, handleBack, handleAvatarSubmit } =
    useRegisterContext();

  const selected = AVATARS.find((a) => a.id === selectedAvatar)!;
  const SelectedComp = AVATAR_COMPONENTS[selected.id];

  return (
    <form onSubmit={handleAvatarSubmit} className="flex flex-col gap-5">
      <div className="flex justify-center">
        <div
          key={selectedAvatar}
          className="animate-pop-in w-[140px] h-[140px] rounded-full border-4 border-ink flex items-center justify-center shadow-[0_6px_0_0_#2A1B3D]"
          style={{ background: selected.bg }}
        >
          <SelectedComp size={100} />
        </div>
      </div>

      <div className="grid grid-cols-5 gap-3 max-w-[420px] mx-auto">
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

      <div className="bg-cream-2 border-[3px] border-ink rounded-lg p-4 flex items-center gap-3 text-left">
        <Sparkle size={26} className="text-gold" />
        <div>
          <Typography as="div" variant="label" className="font-bold">
            Your first quest is free!
          </Typography>
          <Typography
            as="div"
            variant="caption"
            className="text-[12px] text-ink-soft font-semibold"
          >
            Defend the village. Solve 5 equations.
          </Typography>
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
    <div className="flex flex-col gap-2">
      <Typography as="h1" variant="display" className="text-[38px]">
        {step === 1 ? "Start your quest" : "Pick your wizard"}
      </Typography>
      <Typography variant="label" className="text-ink-soft">
        {step === 1
          ? "A few quick questions and you're in."
          : "Your hero awaits — choose wisely!"}
      </Typography>
    </div>
  );
}

function RegisterCard() {
  const { step, loading } = useRegisterContext();
  return (
    <AuthPageLayout>
      <div className="absolute top-6 left-[8%] animate-float-slow">
        <CloudPixel variant="1" className="w-[186px]" />
      </div>
      <div className="absolute top-14 right-[10%] animate-float">
        <Sparkle size={28} className="text-gold" />
      </div>
      <div className="absolute bottom-16 left-[12%] animate-float-fast">
        <Sparkle size={24} className="text-teal" />
      </div>
      <div className="absolute bottom-16 right-[6%] animate-float-slow">
        <Coin size={48} />
      </div>

      <AuthCard>
        <div className="flex flex-col gap-6">
          <RegisterHeader />
          <StepDots currentStep={step} totalSteps={2} />
          {step === 1 && <InfoStep />}
          {step === 2 && <AvatarStep />}
        </div>
      </AuthCard>

      {loading && <LoadingOverlay text="Summoning your wizard..." />}
    </AuthPageLayout>
  );
}

export function RegisterPage() {
  return (
    <RegisterProvider>
      <RegisterCard />
    </RegisterProvider>
  );
}
