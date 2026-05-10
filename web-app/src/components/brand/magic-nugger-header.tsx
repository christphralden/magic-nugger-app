import { Typography } from "@/components/ui/typography";

export function MagicNuggerHeader() {
  return (
    <div className="w-full flex items-center justify-center pt-6 pb-4 bg-cream">
      <Typography as="h2" variant={"logo"}>
        Magic Nugger
      </Typography>
    </div>
  );
}
