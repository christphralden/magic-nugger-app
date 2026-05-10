import { Link } from "react-router-dom";
import { MagicNuggerLogo } from "./magic-nugger-logo";

export function MagicNuggerHeader() {
  return (
    <Link
      to={"/"}
      className="w-full flex items-center justify-center pt-6 pb-4 bg-cream"
    >
      <MagicNuggerLogo />
    </Link>
  );
}
