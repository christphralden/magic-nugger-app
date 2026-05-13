import {
  PATH_TO_UNITY,
  UNITY_GAME_OBJECT,
  UNITY_SEND_METHOD,
  UNITY_SUBSCRIBED_EVENT,
} from "@/constants";
import {
  createGameSession,
  endGameSession,
  failGameSession,
  submitAnswer,
} from "@/feature/game/state/game.thunk";
import { getMe } from "@/feature/auth/state/auth.thunk";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import {
  selectLevels,
  selectUnlockedLevelNames,
} from "@/feature/levels/state/levels.slice";
import { useDispatch, useSelector } from "@/store/hooks";
import { useCallback, useEffect, useRef } from "react";
import { Unity, useUnityContext } from "react-unity-webgl";

export function useUnityBridge() {
  const dispatch = useDispatch();
  const currentPlayer = useSelector(selectCurrentPlayer);
  const unlockedNames = useSelector(selectUnlockedLevelNames);
  const levels = useSelector(selectLevels);

  const sessionIdRef = useRef<string | null>(null);
  const {
    unityProvider: provider,
    sendMessage,
    isLoaded,
    addEventListener,
    removeEventListener,
  } = useUnityContext({
    loaderUrl: `${PATH_TO_UNITY}/Calculon.loader.js`,
    dataUrl: `${PATH_TO_UNITY}/Calculon.data`,
    frameworkUrl: `${PATH_TO_UNITY}/Calculon.framework.js`,
    codeUrl: `${PATH_TO_UNITY}/Calculon.wasm`,
  });

  const handleInit = useCallback(() => {
    if (!currentPlayer) return;
    sendMessage(
      UNITY_GAME_OBJECT,
      UNITY_SEND_METHOD.GIVE_INITIAL_DATA,
      JSON.stringify({
        all_levels_unlocked: unlockedNames,
        current_elo: currentPlayer.current_elo,
      }),
    );
  }, [sendMessage, currentPlayer, unlockedNames]);

  const handleLevel = useCallback(
    (levelName: unknown) => {
      const level = levels.find((l) => l.name === levelName);
      if (!level) {
        console.error(`[useUnityBridge] Level "${levelName}" not found in DB. Ensure Unity LevelData.levelName matches the DB level name.`);
        return;
      }
      const startSession = async () => {
        const result = await dispatch(
          createGameSession({ level_id: level.id }),
        );
        if (createGameSession.fulfilled.match(result)) {
          sessionIdRef.current = result.payload.id;
        }
      };
      startSession();
    },
    [dispatch, levels],
  );

  const handleAnswer = useCallback(
    (correct: unknown) => {
      if (!sessionIdRef.current) return;
      dispatch(
        submitAnswer({
          sessionId: sessionIdRef.current,
          is_correct: Boolean(correct),
        }),
      );
    },
    [dispatch],
  );

  const handleFinished = useCallback(
    (alive: unknown) => {
      if (!sessionIdRef.current) return;
      const sessionId = sessionIdRef.current;
      sessionIdRef.current = null;
      const finishSession = async () => {
        const thunk = alive ? endGameSession : failGameSession;
        const result = await dispatch(thunk({ sessionId }));
        if (
          endGameSession.fulfilled.match(result) ||
          failGameSession.fulfilled.match(result)
        ) {
          sendMessage(
            UNITY_GAME_OBJECT,
            UNITY_SEND_METHOD.FINALIZED,
            JSON.stringify(result.payload),
          );
          dispatch(getMe());
        }
      };
      finishSession();
    },
    [dispatch, sendMessage],
  );

  useEffect(() => {
    addEventListener(UNITY_SUBSCRIBED_EVENT.INIT, handleInit);
    return () => removeEventListener(UNITY_SUBSCRIBED_EVENT.INIT, handleInit);
  }, [addEventListener, removeEventListener, handleInit]);

  useEffect(() => {
    addEventListener(UNITY_SUBSCRIBED_EVENT.LEVEL, handleLevel);
    return () => removeEventListener(UNITY_SUBSCRIBED_EVENT.LEVEL, handleLevel);
  }, [addEventListener, removeEventListener, handleLevel]);

  useEffect(() => {
    addEventListener(UNITY_SUBSCRIBED_EVENT.ANSWER, handleAnswer);
    return () =>
      removeEventListener(UNITY_SUBSCRIBED_EVENT.ANSWER, handleAnswer);
  }, [addEventListener, removeEventListener, handleAnswer]);

  useEffect(() => {
    addEventListener(UNITY_SUBSCRIBED_EVENT.FINISHED, handleFinished);
    return () =>
      removeEventListener(UNITY_SUBSCRIBED_EVENT.FINISHED, handleFinished);
  }, [addEventListener, removeEventListener, handleFinished]);

  return {
    Unity,
    provider,
    isLoaded,
  };
}
