import { Routes, Route, Navigate } from "react-router-dom";
import { Authenticated } from "@/components/guards/authenticated";
import { AdminOnly } from "@/components/guards/admin-only";
import { LandingPage } from "@/pages/landing";
import { LoginPage } from "@/pages/login";
import { RegisterPage } from "@/pages/register";
import { HomePageContainer } from "@/pages/home";
import { LevelSelectPage } from "@/pages/level-select";
import { GamePage } from "@/pages/game";
import { NewGamePage } from "@/pages/game-new";
import { NewRoomPage } from "@/pages/room-new";
import { RoomLobbyPage } from "@/pages/room-lobby";
import { RoomFinishedPage } from "@/pages/room-finished";
import {
  ProfilePageContainer,
  ProfileTab,
  StatisticsTab,
} from "@/pages/profile";
import { LeaderboardPage } from "@/pages/leaderboard";
import { ClassroomPage } from "@/pages/classroom";
import { LogoutPage } from "@/pages/logout";
import { AdminLayout } from "@/pages/admin";
import { DashboardTab } from "@/feature/admin/tabs/dashboard";
import { PlayersTab } from "@/feature/admin/tabs/players";
import { SessionsTab } from "@/feature/admin/tabs/sessions";
import { LevelsTab } from "@/feature/admin/tabs/levels";
import { CreateLevelTab } from "@/feature/admin/tabs/create-level";
import { SystemTab } from "@/feature/admin/tabs/system";

function App() {
  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />
      <Route path="/logout" element={<LogoutPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />

      <Route element={<Authenticated redirectTo="/login" />}>
        <Route path="/home" element={<HomePageContainer />} />

        <Route path="/settings" element={<ProfilePageContainer />}>
          <Route index element={<Navigate to="profile" replace />} />
          <Route path="profile" element={<ProfileTab />} />
          <Route path="statistics" element={<StatisticsTab />} />
        </Route>

        <Route path="/levels" element={<LevelSelectPage />} />
        <Route path="/leaderboard" element={<LeaderboardPage />} />
        <Route path="/classroom" element={<ClassroomPage />} />

        <Route path="/game">
          <Route index element={<GamePage />} />
          <Route path="new" element={<NewGamePage />} />
          <Route path="room">
            <Route path="new" element={<NewRoomPage />} />
            <Route path=":id">
              <Route index element={<RoomLobbyPage />} />
              <Route path="play" element={<NewGamePage />} />
              <Route path="finished" element={<RoomFinishedPage />} />
            </Route>
          </Route>
        </Route>

        <Route element={<AdminOnly redirectTo="/home" />}>
          <Route path="/admin" element={<AdminLayout />}>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={<DashboardTab />} />
            <Route path="players" element={<PlayersTab />} />
            <Route path="sessions" element={<SessionsTab />} />
            <Route path="levels" element={<LevelsTab />} />
            <Route path="levels/create" element={<CreateLevelTab />} />
            <Route path="system" element={<SystemTab />} />
          </Route>
        </Route>
      </Route>
    </Routes>
  );
}

export default App;
