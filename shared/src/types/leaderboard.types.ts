export type LeaderboardPeriod = "week" | "month" | "alltime";

export type BaseLeaderboardRow = {
  player_id: string;
  username: string;
  display_name: string | null;
  avatar_url: string | null;
};

export type GlobalLeaderboardRow = BaseLeaderboardRow & {
  current_elo: number;
  max_streak: number;
};

export type LevelLeaderboardRow = BaseLeaderboardRow & {
  best_score: number;
  max_streak: number;
};

export type ClassroomLeaderboardRow = BaseLeaderboardRow & {
  classroom_elo: number;
  max_streak: number;
};

export type RoomLeaderboardRow = BaseLeaderboardRow & {
  game_session_id: string | null;
  score: number | null;
  elo_delta: number | null;
  correct_count: number | null;
  incorrect_count: number | null;
  max_streak: number | null;
  session_status: string | null;
  finished_at: string | null;
};
