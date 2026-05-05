import type { AppUser, ResponsePlayer } from "@magic-nugger-app/shared";

export function toResponsePlayer(user: AppUser | null | undefined): ResponsePlayer | null {
  if (!user) return null;
  return {
    id: user.id,
    username: user.username,
    display_name: user.display_name,
    current_elo: user.current_elo,
    highest_level_unlocked: user.highest_level_unlocked,
    avatar_url: user.avatar_url,
  };
}
