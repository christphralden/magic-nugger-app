import { type ReactNode } from "react";
import { cn } from "@/lib/utils";
import { MagicNuggerHeader } from "@/components/brand/magic-nugger-header";

interface AuthPageLayoutProps {
  children: ReactNode;
}

export function AuthPageLayout({ children }: AuthPageLayoutProps) {
  return (
    <div className="min-h-screen bg-background font-body flex flex-col overflow-hidden">
      <MagicNuggerHeader />
      <div className="flex-1 relative flex items-center justify-center px-6 py-10">
        {children}
      </div>
    </div>
  );
}

interface AuthCardProps {
  children: ReactNode;
  className?: string;
}

export function AuthCard({ children, className }: AuthCardProps) {
  return (
    <div
      className={cn(
        "animate-pop-in w-full max-w-xl bg-paper border-[3px] border-border",
        "rounded-xl shadow-cartoon-lg p-10 text-center",
        className,
      )}
    >
      {children}
    </div>
  );
}
