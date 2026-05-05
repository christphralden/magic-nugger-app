import { Routes, Route } from "react-router-dom";
import { LandingPage } from "@/pages/landing";
import { LoginPage } from "@/pages/login";
import { RegisterPage } from "@/pages/register";
import { LevelSelectPage } from "@/pages/level-select";
import { GamePage } from "@/pages/game";
import { ProfilePage } from "@/pages/profile";
import { LeaderboardPage } from "@/pages/leaderboard";
import { ClassroomPage } from "@/pages/classroom";

function App() {
  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/levels" element={<LevelSelectPage />} />
      <Route path="/game" element={<GamePage />} />
      <Route path="/profile" element={<ProfilePage />} />
      <Route path="/leaderboard" element={<LeaderboardPage />} />
      <Route path="/classroom" element={<ClassroomPage />} />
    </Routes>
  );
}

export default App;
