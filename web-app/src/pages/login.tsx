import { LoginProvider, useLoginContext } from "@/contexts/login.context";
import { Button } from "@/components/ui/button";
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
import { LoadingOverlay } from "@/components/ui/loading-overlay";
import { GoogleIcon } from "@/components/icons/google-icon";
import { EyeIcon } from "@/components/icons/eye-icon";
import { Cloud } from "@/components/decor/cloud";
import { Sparkle } from "@/components/decor/sparkle";
import { Coin } from "@/components/decor/coin";
import { cn } from "@/lib/utils";
import { Typography } from "@/components/ui/typography";
import { AuthPageLayout, AuthCard } from "@/components/layout/auth-layout";
import { CloudPixel } from "@/components/decor/cloud-pixel";

function LoginGoogleButton() {
  return (
    <CartoonButton variant="secondary" className="w-full" type="button">
      <GoogleIcon /> Continue with Google
    </CartoonButton>
  );
}

function LoginEmailField() {
  const { form } = useLoginContext();
  return (
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
              placeholder="merlin@realm.com"
              {...field}
            />
          </FormControl>
        </FormItem>
      )}
    />
  );
}

function LoginPasswordField() {
  const { form, showPassword, handleTogglePassword } = useLoginContext();
  return (
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
              placeholder="••••••••"
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
  );
}

function LoginFormFooter() {
  const { rememberMe, handleToggleRememberMe, handleForgotPassword } =
    useLoginContext();
  return (
    <div className="flex justify-between items-center">
      <Button
        type="button"
        variant={"ghost"}
        className="flex items-center gap-2.5 text-[14px] text-ink-soft cursor-pointer px-0"
        onClick={handleToggleRememberMe}
      >
        <span
          className={cn(
            "w-[22px] h-[22px] border-[3px] border-border rounded-[6px] bg-paper flex-shrink-0 inline-flex items-center justify-center",
            rememberMe && "bg-gold",
          )}
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
        <Typography variant={"label"}>Keep me signed in</Typography>
      </Button>
      <Button
        type="button"
        variant="ghost"
        className="font-bold text-[14px] text-coral p-0 h-auto hover:bg-transparent"
        onClick={handleForgotPassword}
      >
        <Typography variant={"label"}>Forgot password?</Typography>
      </Button>
    </div>
  );
}

function LoginForm() {
  const { form, handleSubmit } = useLoginContext();
  return (
    <Form {...form}>
      <form
        noValidate
        onSubmit={handleSubmit}
        className="text-left flex flex-col gap-4"
      >
        <LoginEmailField />
        <LoginPasswordField />
        <LoginFormFooter />
        <CartoonButton type="submit" variant="primary" className="w-full">
          <Sparkle size={22} /> Enter the Realm
        </CartoonButton>
      </form>
    </Form>
  );
}

function LoginSignupLink() {
  const { handleNavigateRegister } = useLoginContext();
  return (
    <Typography variant="label" className="text-ink-soft">
      New here?{" "}
      <Button
        variant={"link"}
        className="text-coral font-extrabold underline decoration-[3px] underline-offset-4 text-[15px] px-0"
        onClick={handleNavigateRegister}
      >
        Create an account
      </Button>
    </Typography>
  );
}

function LoginCard() {
  const { loading } = useLoginContext();
  return (
    <AuthPageLayout>
      <div className="absolute top-6 left-[8%] animate-float-slow">
        <CloudPixel variant="1" className="w-[186px]" />
      </div>
      <div className="absolute top-14 right-[10%] animate-float">
        <Sparkle size={28} className="text-gold" />
      </div>
      <div className="absolute bottom-16 left-[12%] animate-float-fast">
        <Sparkle size={24} className="text-coral" />
      </div>
      <div className="absolute bottom-16 right-[6%] animate-float-slow">
        <Coin size={48} />
      </div>

      <AuthCard>
        <div className="flex flex-col gap-6">
          <div className="flex flex-col gap-2">
            <Typography as="h1" variant="primary">
              Welcome back!
            </Typography>
            <Typography variant="label">Your hero missed you</Typography>
          </div>
          <LoginGoogleButton />
          <LoginForm />
          <LoginSignupLink />
        </div>
      </AuthCard>

      {loading && <LoadingOverlay text="Casting your spell..." />}
    </AuthPageLayout>
  );
}

export function LoginPage() {
  return (
    <LoginProvider>
      <LoginCard />
    </LoginProvider>
  );
}
