import type { AppUser, ResponsePlayer } from "@magic-nugger-app/shared";

export function toResponsePlayer(
  user: AppUser | null | undefined,
): ResponsePlayer | null {
  if (!user) return null;
  return {
    id: user.id,
    username: user.username,
    email: user.email,
    display_name: user.display_name,
    role_name: user.role_name,
    current_elo: user.current_elo,
    highest_level_unlocked: user.highest_level_unlocked,
    avatar_url: user.avatar_url,
    age: user.age,
    grade: user.grade,
    guardian_email: user.guardian_email,
    total_questions_answered: user.total_questions_answered ?? 0,
    total_correct: user.total_correct ?? 0,
    total_incorrect: user.total_incorrect ?? 0,
    longest_streak: user.longest_streak ?? 0,
  };
}
