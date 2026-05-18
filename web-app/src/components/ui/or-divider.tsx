import { Typography } from "@/components/ui/typography";

export function OrDivider() {
  return (
    <div className="flex items-center gap-4">
      <span className="w-16 h-[3px] bg-ink-soft rounded-sm" />
      <Typography variant="label" as="span">
        OR
      </Typography>
      <span className="w-16 h-[3px] bg-ink-soft rounded-sm" />
    </div>
  );
}
