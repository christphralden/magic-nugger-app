import { ReactNode } from "react";

interface AvatarPickButtonProps {
  bg: string;
  selected: boolean;
  onClick: () => void;
  children: ReactNode;
}

export function AvatarPickButton({
  bg,
  selected,
  onClick,
  children,
}: AvatarPickButtonProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      style={{ background: bg }}
      className={[
        "aspect-square rounded-full border-[3px] border-border flex items-center justify-center cursor-pointer transition-all duration-150",
        "hover:-translate-y-1",
        selected ? "shadow-avatar-selected -translate-y-1" : "",
      ]
        .filter(Boolean)
        .join(" ")}
    >
      {children}
    </button>
  );
}
