import { Typography } from "@/components/ui/typography";
import { CartoonButton } from "@/components/ui/cartoon-button";

type Props = {
  title: string;
  description: string;
  onConfirm: () => void;
  onCancel: () => void;
};

export function ConfirmLeaveDialog({ title, description, onConfirm, onCancel }: Props) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-ink/50 backdrop-blur-sm">
      <div className="bg-paper border-[3px] border-border rounded-xl shadow-cartoon-lg p-8 w-full max-w-sm flex flex-col gap-6">
        <div className="flex flex-col gap-2">
          <Typography variant="primary">{title}</Typography>
          <Typography variant="secondary" className="text-ink-soft">
            {description}
          </Typography>
        </div>
        <div className="flex gap-3">
          <CartoonButton variant="secondary" onClick={onCancel} className="flex-1">
            Stay
          </CartoonButton>
          <CartoonButton onClick={onConfirm} className="flex-1">
            Leave
          </CartoonButton>
        </div>
      </div>
    </div>
  );
}
