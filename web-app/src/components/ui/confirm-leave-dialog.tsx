import * as DialogPrimitive from "@radix-ui/react-dialog";
import { DialogOverlay, DialogPortal } from "@/components/ui/dialog";
import { Typography } from "@/components/ui/typography";
import { CartoonButton } from "@/components/ui/cartoon-button";

type Props = {
  title: string;
  description: string;
  onConfirm: () => void;
  onCancel: () => void;
};

export function ConfirmLeaveDialog({
  title,
  description,
  onConfirm,
  onCancel,
}: Props) {
  return (
    <DialogPrimitive.Root
      open
      onOpenChange={(open) => {
        if (!open) onCancel();
      }}
    >
      <DialogPortal>
        <DialogOverlay className="bg-ink/50 backdrop-blur-sm" />
        <DialogPrimitive.Content className="fixed left-1/2 top-1/2 z-50 w-full max-w-sm -translate-x-1/2 -translate-y-1/2 bg-paper border-[3px] border-border rounded-xl shadow-cartoon-lg px-6 py-4 flex flex-col gap-2 focus:outline-none">
          <DialogPrimitive.Title asChild>
            <Typography variant="subheading">{title}</Typography>
          </DialogPrimitive.Title>
          <DialogPrimitive.Description asChild>
            <Typography variant="label" className="text-ink-soft">
              {description}
            </Typography>
          </DialogPrimitive.Description>
          <div className="flex gap-3 mt-4">
            <CartoonButton
              size="sm"
              variant="secondary"
              onClick={onCancel}
              className="flex-1"
            >
              Stay
            </CartoonButton>
            <CartoonButton size="sm" onClick={onConfirm} className="flex-1">
              Leave
            </CartoonButton>
          </div>
        </DialogPrimitive.Content>
      </DialogPortal>
    </DialogPrimitive.Root>
  );
}
