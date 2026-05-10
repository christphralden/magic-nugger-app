import { Typography } from "@/components/ui/typography";
import { Link } from "react-router-dom";

export function MagicNuggerHeader() {
  return (
    <Link
      to={"/"}
      className="w-full flex items-center justify-center pt-6 pb-4 bg-cream"
    >
      <Typography as="h2" variant={"logo"}>
        Calculon
      </Typography>
    </Link>
  );
}
