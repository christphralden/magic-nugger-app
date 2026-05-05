interface LoadingOverlayProps {
  text: string;
  subtext?: string;
}

export function LoadingOverlay({ text, subtext = "Polishing the nuggets" }: LoadingOverlayProps) {
  return (
    <div className="fixed inset-0 bg-ink/55 flex items-center justify-center z-[100] backdrop-blur-sm">
      <div className="animate-pop-in bg-white border-[3px] border-ink rounded-cartoon-lg shadow-[0_10px_0_0_#2A1B3D] px-14 py-10 flex flex-col items-center gap-[18px] text-center">
        <div className="w-16 h-16 rounded-full border-[6px] border-cream-2 border-t-coral animate-spin-slow" />
        <div className="font-display font-bold text-[22px] text-ink">{text}</div>
        <div className="text-sm text-ink-soft font-semibold">{subtext}</div>
      </div>
    </div>
  );
}
