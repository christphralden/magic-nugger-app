import { useEffect, type ReactNode } from "react";
import { Link } from "react-router-dom";
import { useSelector } from "react-redux";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { Avatar, AvatarImage, AvatarFallback } from "../ui/avatar";
import { MagicNuggerLogo } from "../brand/magic-nugger-logo";
import { IconStreak } from "../decor/streak";
import { Typography } from "../ui/typography";

interface PageLayoutProps {
  title: string;
  children: ReactNode;
}

export function PageLayout({ title, children }: PageLayoutProps) {
  const { username, display_name, current_elo } =
    useSelector(selectCurrentPlayer)!;

  const name = display_name || username;
  const avatarFallback = name
    .split(" ", 2)
    .map((v) => v.at(0)?.toUpperCase())
    .join();

  useEffect(() => {
    document.title = `${title} | Magic Nugger`;
  }, [title]);
  return (
    <div className="min-h-screen bg-background">
      <div className="flex items-center justify-between px-8 py-4 border-b-[3px] border-border bg-paper">
        <section>
          <Link to={"/home"}>
            <MagicNuggerLogo />
          </Link>
        </section>

        <section className="flex items-center gap-6">
          <div className="flex gap-1">
            <IconStreak className="fill-coral size-5" />
            <Typography variant={"label"}>{current_elo}</Typography>
          </div>
          <Link to="/settings/profile" className="flex items-center gap-2">
            <Avatar className="size-8">
              <AvatarImage src="https://github.com/shadcn.png" />
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
