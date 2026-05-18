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
import { Alert } from "@/components/ui/alert";
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
            className={`h-3 border-[3px] border-border rounded-full transition-all duration-200 ${
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
          noValidate
          onSubmit={handleInfoNext}
          className="text-left flex flex-col gap-4 mt-5"
        >
          <FormField
            control={form.control}
            name="username"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>Hero name</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput placeholder="merlin_the_brave" {...field} />
                </FormControl>
              </FormItem>
            )}
          />

          <div className="grid grid-cols-[1fr_1fr] gap-3 items-end">
            <FormField
              control={form.control}
              name="age"
              render={({ field }) => (
                <FormItem>
                  <div className="flex gap-2 items-center">
                    <FormLabel>Age</FormLabel>
                    <FormMessage />
                  </div>
                  <FormControl>
                    <CartoonInput
                      type="number"
                      min="6"
                      max="14"
                      placeholder="9"
                      {...field}
                    />
                  </FormControl>
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="grade"
              render={({ field }) => (
                <FormItem>
                  <div className="flex gap-2 items-center">
                    <FormLabel>Grade</FormLabel>
                    <FormMessage />
                  </div>
                  <CartoonSelect
                    options={GRADES}
                    value={field.value}
                    onValueChange={field.onChange}
                  />
                </FormItem>
              )}
            />
          </div>

          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>Email</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput
                    type="email"
                    placeholder="merlinthehero@email.com"
                    {...field}
                  />
                </FormControl>
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>Password</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput
                    type={showPassword ? "text" : "password"}
                    placeholder="at least 6 magic letters"
                    rightSlot={
                      <Button
                        type="button"
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
              </FormItem>
            )}
          />

          <CartoonButton
            type="submit"
            variant="primary"
            className="w-full items-center"
          >
            Next: pick your hero <ArrowRightIcon size={20} />
          </CartoonButton>
        </form>
      </Form>

      <Typography variant="label" className="mt-6 text-ink-soft">
        Already a hero?{" "}
        <Button
          variant={"link"}
          className="text-coral underline decoration-[3px] underline-offset-4 px-0"
          onClick={handleNavigateLogin}
        >
          <Typography variant="label">Sign in</Typography>
        </Button>
      </Typography>
    </>
  );
}

function AvatarStep() {
  const {
    form,
    selectedAvatar,
    handleSelectAvatar,
    handleBack,
    handleAvatarSubmit,
  } = useRegisterContext();

  const selected = AVATARS.find((a) => a.id === selectedAvatar)!;
  const SelectedComp = AVATAR_COMPONENTS[selected.id];

  return (
    <form onSubmit={handleAvatarSubmit} className="flex flex-col gap-5">
      <div className="flex justify-center">
        <div
          key={selectedAvatar}
          className="animate-pop-in w-[140px] h-[140px] rounded-full border-4 border-border flex items-center justify-center shadow-[0_6px_0_0_#2A1B3D]"
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

      {form.formState.errors.root && (
        <Alert
          variant="error"
          title="Something went wrong"
          description={form.formState.errors.root.message}
        />
      )}

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
        </CartoonButton>
      </div>
    </form>
  );
}

function RegisterHeader() {
  const { step } = useRegisterContext();
  return (
    <div className="flex flex-col gap-2">
      <Typography as="h1" variant="primary">
        {step === 1 ? "Start your quest" : "Pick your hero"}
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

      {loading && <LoadingOverlay text="Summoning your hero..." />}
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
