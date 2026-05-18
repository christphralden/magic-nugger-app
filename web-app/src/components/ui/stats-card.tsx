import { Typography } from "./typography";

export function StatCard({
  label,
  value,
}: {
  label: string;
  value: string | number;
}) {
  return (
    <div className="flex flex-col gap-1 rounded-lg bg-white p-4 border-border border-[3px] shadow-cartoon-sm">
      <Typography variant="label" className="text-ink-soft">
        {label}
      </Typography>
      <Typography variant="subheading">{value}</Typography>
    </div>
  );
}
