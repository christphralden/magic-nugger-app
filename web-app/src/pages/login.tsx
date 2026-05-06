import { LoginProvider, useLoginContext } from "@/contexts/login.context";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { LoadingOverlay } from "@/components/ui/loading-overlay";
import { MagicNuggerHeader } from "@/components/brand/magic-nugger-header";
import { GoogleIcon } from "@/components/icons/google-icon";
import { EyeIcon } from "@/components/icons/eye-icon";
import { PlayIcon } from "@/components/icons/play-icon";
import { ArrowRightIcon } from "@/components/icons/arrow-right-icon";
import { Cloud } from "@/components/decor/cloud";
import { Sparkle } from "@/components/decor/sparkle";
import { Coin } from "@/components/decor/coin";
import { cn } from "@/lib/utils";

function LoginGoogleButton() {
  return (
    <CartoonButton variant="secondary" className="w-full mb-5" type="button">
      <GoogleIcon /> Continue with Google
    </CartoonButton>
  );
}

function LoginUsernameField() {
  const { form } = useLoginContext();
  return (
    <FormField
      control={form.control}
      name="username"
      render={({ field }) => (
        <FormItem className="mb-4">
          <FormLabel className="font-display font-semibold text-ink text-[15px] tracking-wide">
            Username or email
          </FormLabel>
          <FormControl>
            <Input
              placeholder="merlin_the_brave"
              className="bg-paper border-[3px] border-ink rounded-cartoon-md px-[18px] py-4 text-[17px] text-ink font-semibold h-auto placeholder:text-placeholder placeholder:font-medium focus-visible:ring-0 focus-visible:ring-offset-0 focus:bg-white focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]"
              {...field}
            />
          </FormControl>
          <FormMessage className="text-coral text-[13px] font-semibold" />
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
        <FormItem className="mb-3">
          <FormLabel className="font-display font-semibold text-ink text-[15px] tracking-wide">
            Secret password
          </FormLabel>
          <FormControl>
            <div className="relative">
              <Input
                type={showPassword ? "text" : "password"}
                placeholder="••••••••"
                className="bg-paper border-[3px] border-ink rounded-cartoon-md px-[18px] py-4 pr-12 text-[17px] text-ink font-semibold h-auto placeholder:text-placeholder placeholder:font-medium focus-visible:ring-0 focus-visible:ring-offset-0 focus:bg-white focus:shadow-[0_0_0_4px_rgba(255,182,39,0.45)]"
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
  );
}

function LoginFormFooter() {
  const { rememberMe, handleToggleRememberMe, handleForgotPassword } = useLoginContext();
  return (
    <div className="flex justify-between items-center mb-6">
      <button
        type="button"
        className="flex items-center gap-2.5 text-[14px] text-ink-soft cursor-pointer"
        onClick={handleToggleRememberMe}
      >
        <span
          className={cn(
            "w-[22px] h-[22px] border-[3px] border-ink rounded-[6px] bg-white flex-shrink-0 inline-flex items-center justify-center",
            rememberMe && "bg-gold"
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
        Keep me signed in
      </button>
      <Button
        type="button"
        variant="ghost"
        className="font-bold text-[14px] text-coral p-0 h-auto hover:bg-transparent"
        onClick={handleForgotPassword}
      >
        Forgot password?
      </Button>
    </div>
  );
}

function LoginForm() {
  const { form, handleSubmit } = useLoginContext();
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(handleSubmit)} className="text-left">
        <LoginUsernameField />
        <LoginPasswordField />
        <LoginFormFooter />
        <CartoonButton type="submit" variant="primary" className="w-full">
          <PlayIcon size={22} /> Enter the Realm <ArrowRightIcon size={20} />
        </CartoonButton>
      </form>
    </Form>
  );
}

function LoginSignupLink() {
  const { handleNavigateRegister } = useLoginContext();
  return (
    <p className="mt-6 text-[15px] text-ink-soft font-semibold">
      New here?{" "}
      <button
        className="text-coral font-extrabold underline decoration-[3px] underline-offset-4 text-[15px]"
        onClick={handleNavigateRegister}
      >
        Create an account
      </button>
    </p>
  );
}

function LoginCard() {
  const { loading } = useLoginContext();
  return (
    <div className="min-h-screen bg-cream font-body flex flex-col overflow-hidden">
      <MagicNuggerHeader />

      <div className="flex-1 relative flex items-center justify-center px-6 py-10">
        <div className="absolute top-6 left-[8%] animate-float-slow">
          <Cloud size={120} />
        </div>
        <div className="absolute top-14 right-[10%] animate-float">
          <Sparkle size={28} className="text-gold" />
        </div>
        <div className="absolute bottom-[60px] left-[12%] animate-float-fast">
          <Sparkle size={24} className="text-coral" />
        </div>
        <div className="absolute bottom-16 right-[6%] animate-float-slow">
          <Coin size={48} />
        </div>

        <div className="animate-pop-in w-full max-w-[480px] bg-white border-[3px] border-ink rounded-cartoon-lg shadow-cartoon-lg px-10 py-10 text-center">
          <h1 className="font-display font-bold text-ink text-[40px] leading-[0.95] mb-2">Welcome back!</h1>
          <p className="text-[16px] text-ink-soft font-semibold mb-7">Your towers missed you</p>
          <LoginGoogleButton />
          <LoginForm />
          <LoginSignupLink />
        </div>
      </div>

      {loading && <LoadingOverlay text="Casting your spell..." />}
    </div>
  );
}

export function LoginPage() {
  return (
    <LoginProvider>
      <LoginCard />
    </LoginProvider>
  );
}
