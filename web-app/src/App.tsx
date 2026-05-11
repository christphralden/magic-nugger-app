import { Routes, Route, Navigate } from "react-router-dom";
import { Authenticated } from "@/components/guards/authenticated";
import { LandingPage } from "@/pages/landing";
import { LoginPage } from "@/pages/login";
import { RegisterPage } from "@/pages/register";
import { HomePageContainer } from "@/pages/home";
import { LevelSelectPage } from "@/pages/level-select";
import { GamePage } from "@/pages/game";
import { ProfilePageContainer, ProfileTab, StatisticsTab } from "@/pages/profile";
import { LeaderboardPage } from "@/pages/leaderboard";
import { ClassroomPage } from "@/pages/classroom";
import { LogoutPage } from "@/pages/logout";

function App() {
  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />
      <Route path="/logout" element={<LogoutPage />} />

      <Route element={<Authenticated redirectTo="/home" ifAuthenticated />}>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
      </Route>

      <Route element={<Authenticated redirectTo="/login" />}>
        <Route path="/home" element={<HomePageContainer />} />
        <Route path="/settings" element={<ProfilePageContainer />}>
          <Route index element={<Navigate to="profile" replace />} />
          <Route path="profile" element={<ProfileTab />} />
          <Route path="statistics" element={<StatisticsTab />} />
        </Route>
        <Route path="/levels" element={<LevelSelectPage />} />
        <Route path="/game" element={<GamePage />} />
        <Route path="/leaderboard" element={<LeaderboardPage />} />
        <Route path="/classroom" element={<ClassroomPage />} />
      </Route>
    </Routes>
  );
}

export default App;
