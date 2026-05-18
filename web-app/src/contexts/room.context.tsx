import {
  createContext,
  useContext,
  useState,
  type Dispatch,
  type SetStateAction,
} from "react";
import { useNavigate, useParams, Outlet } from "react-router-dom";
import { useSelector } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { toastError, toastInfo } from "@/lib/toast";
import type { RoomWithMembers, ResponsePlayer } from "@magic-nugger-app/shared";

interface RoomContextValue {
  roomId: string;
  roomData: RoomWithMembers | null;
  setRoomData: Dispatch<SetStateAction<RoomWithMembers | null>>;
  isHost: boolean;
  currentPlayer: ResponsePlayer | null;
  handleRoomCancelled: () => void;
  onSseError: (status: number) => void;
}

const RoomContext = createContext<RoomContextValue | null>(null);

export function useRoom() {
  const ctx = useContext(RoomContext);
  if (!ctx) throw new Error("useRoom must be used within RoomProvider");
  return ctx;
}

export function RoomProvider() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const currentPlayer = useSelector(selectCurrentPlayer);
  const [roomData, setRoomData] = useState<RoomWithMembers | null>(null);

  const roomId = id!;
  const isHost = currentPlayer?.id === roomData?.room.host_id;

  const handleRoomCancelled = () => {
    toastInfo(
      isHost ? "The room has been destroyed" : "The room has been destroyed by the host",
    );
    navigate("/game/room/new");
  };

  const onSseError = (status: number) => {
    toastError(status === 403 ? "No access to this room" : "Room connection failed");
    navigate("/game/room/new");
  };

  return (
    <RoomContext.Provider
      value={{
        roomId,
        roomData,
        setRoomData,
        isHost,
        currentPlayer,
        handleRoomCancelled,
        onSseError,
      }}
    >
      <Outlet />
    </RoomContext.Provider>
  );
}
