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
  headless?: boolean;
}

const NAV_LINKS = [
  { to: "/home", label: "Home" },
  { to: "/levels", label: "Levels" },
  { to: "/game", label: "Game" },
  { to: "/leaderboard", label: "Leaderboard" },
];

export function PageLayout({ title, children, headless }: PageLayoutProps) {
  const player = useSelector(selectCurrentPlayer);

  const location = useLocation();

  const name = player?.display_name || player?.username || "Player";
  const avatarFallback = nameInitials(name);

  useEffect(() => {
    document.title = `${title} | Calculon`;
  }, [title]);

  return (
    <div className="h-screen flex flex-col bg-background overflow-hidden">
      <div className="flex items-center justify-between px-8 py-4 border-b-[3px] border-border bg-paper">
        <section className="flex w-full max-w-64 justify-start">
          <Link to={"/home"} className="flex items-end gap-2">
            <MagicNuggerLogo />
            <Typography
              variant="label"
              className="text-ink-soft font-mono text-xs"
            >
              {__COMMIT_HASH__}
            </Typography>
          </Link>
        </section>

        <nav className="flex items-center gap-6 w-full max-w-64 justify-center">
          {NAV_LINKS.map(({ to, label }) => {
            const isActive =
              to === "/game"
                ? location.pathname.startsWith("/game")
                : location.pathname === to;
            return (
              <Link key={to} to={to}>
                <Typography
                  variant="label"
                  className={cn(
                    "transition-colors",
                    isActive ? "text-coral" : "text-ink-soft hover:text-ink",
                  )}
                >
                  {label}
                </Typography>
              </Link>
            );
          })}
          {player?.role_name === "admin" && (
            <Link to="/admin">
              <Typography
                variant="label"
                className={cn(
                  "transition-colors",
                  location.pathname.startsWith("/admin")
                    ? "text-coral"
                    : "text-ink-soft hover:text-ink",
                )}
              >
                Admin
              </Typography>
            </Link>
          )}
        </nav>

        <section className="flex items-center gap-6 w-full max-w-64 justify-end">
          <div className="flex items-center">
            <IconStreak className="fill-coral size-5" />
            <Typography variant={"label"}>
              {player?.current_elo ?? 0}
            </Typography>
          </div>
          <Link to="/settings/profile" className="flex items-center gap-2">
            <Avatar className="size-8">
              {player?.avatar_url && <AvatarImage src={player.avatar_url} />}
              <AvatarFallback>{avatarFallback}</AvatarFallback>
            </Avatar>

            <Typography variant={"label"}>{name || "Profile"}</Typography>
          </Link>
        </section>
      </div>
      <div
        className={cn(
          headless ? "" : "px-4 py-8 md:px-8 ",
          "flex-1 min-h-0 overflow-auto relative",
        )}
      >
        {children}
      </div>
    </div>
  );
}
