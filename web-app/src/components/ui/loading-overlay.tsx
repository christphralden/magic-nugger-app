import { FloatingText } from "../floating-text";
import { Typography } from "./typography";

interface LoadingOverlayProps {
  text: string;
  subtext?: string;
}

export function LoadingOverlay({
  text,
  subtext = "Polishing the nuggets",
}: LoadingOverlayProps) {
  return (
    <div className="fixed inset-0 bg-ink/55 flex items-center justify-center z-[100] backdrop-blur-sm">
      <div className="animate-pop-in bg-white border-[3px] border-border rounded-lg shadow-cartoon-lg px-14 py-10 flex flex-col items-center gap-[18px] text-center">
        <Typography variant={"primary"}>
          <FloatingText text={text} duration={1} />
        </Typography>
        <Typography variant={"label"}>
          <FloatingText text={subtext} duration={1} />
        </Typography>
      </div>
    </div>
  );
}
