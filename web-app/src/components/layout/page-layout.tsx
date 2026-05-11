import { useEffect, type ReactNode } from "react";
import { Link, useLocation } from "react-router-dom";
import { useSelector } from "react-redux";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { Avatar, AvatarImage, AvatarFallback } from "../ui/avatar";
import { MagicNuggerLogo } from "../brand/magic-nugger-logo";
import { IconStreak } from "../decor/streak";
import { Typography } from "../ui/typography";
import { cn, nameInitials } from "@/lib/utils";

interface PageLayoutProps {
  title: string;
  children: ReactNode;
}

const NAV_LINKS = [
  { to: "/home", label: "Home" },
  { to: "/levels", label: "Levels" },
  { to: "/leaderboard", label: "Leaderboard" },
];

export function PageLayout({ title, children }: PageLayoutProps) {
  const { username, display_name, current_elo, avatar_url } =
    useSelector(selectCurrentPlayer)!;
  const location = useLocation();

  const name = display_name || username;
  const avatarFallback = nameInitials(name);

  useEffect(() => {
    document.title = `${title} | Magic Nugger`;
  }, [title]);
  return (
    <div className="min-h-screen bg-background">
      <div className="flex items-center justify-between px-8 py-4 border-b-[3px] border-border bg-paper">
        <section className="flex w-full max-w-64 justify-start">
          <Link to={"/home"}>
            <MagicNuggerLogo />
          </Link>
        </section>

        <nav className="flex items-center gap-6 w-full max-w-64 justify-center">
          {NAV_LINKS.map(({ to, label }) => (
            <Link key={to} to={to}>
              <Typography
                variant="label"
                className={cn(
                  "transition-colors",
                  location.pathname === to
                    ? "text-coral"
                    : "text-ink-soft hover:text-ink",
                )}
              >
                {label}
              </Typography>
            </Link>
          ))}
        </nav>

        <section className="flex items-center gap-6 w-full max-w-64 justify-end">
          <div className="flex items-center">
            <IconStreak className="fill-coral size-5" />
            <Typography variant={"label"}>{current_elo}</Typography>
          </div>
          <Link to="/settings/profile" className="flex items-center gap-2">
            <Avatar className="size-8">
              {avatar_url && <AvatarImage src={avatar_url} />}
              <AvatarFallback>{avatarFallback}</AvatarFallback>
            </Avatar>

            <Typography variant={"label"}>{name || "Profile"}</Typography>
          </Link>
        </section>
      </div>
      <div className="px-4 py-8 md:px-8">{children}</div>
    </div>
  );
}
