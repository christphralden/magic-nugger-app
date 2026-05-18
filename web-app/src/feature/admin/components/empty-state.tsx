import { Typography } from "@/components/ui/typography";

interface EmptyStateProps {
  message: string;
}

export function EmptyState({ message }: EmptyStateProps) {
  return (
    <div className="p-6">
      <Typography variant="body" className="text-ink-soft">
        {message}
      </Typography>
    </div>
  );
}
