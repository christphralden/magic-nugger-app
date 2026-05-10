import { useEffect, type ReactNode } from "react";
import { Link } from "react-router-dom";
import { LogOut } from "lucide-react";
import { CartoonButton } from "../ui/cartoon-button";
import { useSelector } from "react-redux";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { Avatar, AvatarImage, AvatarFallback } from "../ui/avatar";
import { MagicNuggerLogo } from "../brand/magic-nugger-logo";

interface PageLayoutProps {
  title: string;
  children: ReactNode;
}

export function PageLayout({ title, children }: PageLayoutProps) {
  useEffect(() => {
    document.title = `${title} | Magic Nugger`;
  }, [title]);

  const { username, display_name } = useSelector(selectCurrentPlayer)!;

  const name = display_name || username;
  const avatarFallback = name
    .split(" ", 2)
    .map((v) => v.at(0)?.toUpperCase())
    .join();
  return (
    <div className="min-h-screen bg-cream">
      <div className="flex items-center justify-between px-4 py-2 border-b-[3px] border-ink bg-white">
        <section>
          <MagicNuggerLogo />
        </section>

        <section className="flex items-center gap-4">
          <Link to="/profile" className="flex items-center gap-2">
            <Avatar className="size-6">
              <AvatarImage src="https://github.com/shadcn.png" />
              <AvatarFallback>{avatarFallback}</AvatarFallback>
            </Avatar>
            <CartoonButton variant="ghost" size={"default"} className="!px-0">
              {name || "Profile"}
            </CartoonButton>
          </Link>
          <Link to="/logout">
            <CartoonButton variant="ghost" size={"default"} className="!px-0">
              <LogOut className="size-5" />
              Logout
            </CartoonButton>
          </Link>
        </section>
      </div>
      <div className="px-4 py-8 md:px-8">{children}</div>
    </div>
  );
}
