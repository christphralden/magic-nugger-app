export type LeaderboardPeriod = "week" | "month" | "alltime";

export type GlobalLeaderboardRow = {
  id: string;
  username: string;
  display_name: string | null;
  avatar_url: string | null;
  current_elo: number;
  max_streak: number;
};

export type LevelLeaderboardRow = {
  player_id: string;
  username: string;
  display_name: string | null;
  best_score: number;
  max_streak: number;
};

export type ClassroomLeaderboardRow = {
  player_id: string;
  username: string;
  display_name: string | null;
  classroom_elo: number;
  max_streak: number;
};
