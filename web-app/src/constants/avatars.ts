export type AvatarId = "fox" | "dragon" | "owl" | "bunny" | "robot";

export interface AvatarOption {
  id: AvatarId;
  bg: string;
  label: string;
}

export const AVATARS: ReadonlyArray<AvatarOption> = [
  { id: "fox", bg: "#FFE9B0", label: "Fox" },
  { id: "dragon", bg: "#D4F0CC", label: "Dragon" },
  { id: "owl", bg: "#E8DCFF", label: "Owl" },
  { id: "bunny", bg: "#FFD9E2", label: "Bunny" },
  { id: "robot", bg: "#C7F0EC", label: "Robot" },
];
