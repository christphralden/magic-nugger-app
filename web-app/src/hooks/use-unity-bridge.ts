import {
  PATH_TO_UNITY,
  UNITY_CUSTOM_LEVEL,
  UNITY_GAME_OBJECT,
  UNITY_SEND_METHOD,
  UNITY_SUBSCRIBED_EVENT,
} from "@/constants";
import { isFulfilled } from "@reduxjs/toolkit";
import {
  createGameSession,
  endGameSession,
  failGameSession,
  submitAnswer,
} from "@/feature/game/state/game.thunk";
import { getMe } from "@/feature/auth/state/auth.thunk";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import {
  selectUnlockedLevelNames,
  selectUnlockedLevels,
} from "@/feature/levels/state/levels.slice";
import { useDispatch, useSelector } from "@/store/hooks";
import { useCallback, useEffect, useRef } from "react";
import { Unity, useUnityContext } from "react-unity-webgl";
import type { Question } from "@magic-nugger-app/shared";
import { toastError } from "@/lib/toast";

export function useUnityBridge(
  options: {
    roomId?: string;
    questions?: Question[];
    onCriticalError?: () => void;
    onSessionFinished?: (result: {
      elo_gained: number;
      new_levels_unlocked: string[];
      levelId: number | null;
      score: number;
    }) => void;
  } = {},
) {
  const dispatch = useDispatch();
  const currentPlayer = useSelector(selectCurrentPlayer);
  const unlockedNames = useSelector(selectUnlockedLevelNames);
  const levels = useSelector(selectUnlockedLevels);

  const sessionIdRef = useRef<string | null>(null);
  const lastAnswerAtRef = useRef<number | null>(null);
  const currentLevelIdRef = useRef<number | null>(null);
  const currentScoreRef = useRef<number>(0);

  /**
   * This shit is not working. .data files are ok but .wasm is not available as value in IndexDB,
   * i have no idea theres still an open issue on github for this https://github.com/jeffreylanters/react-unity-webgl/issues/552
   *
   * @param {string} url
   *
   * @returns cache control options
   */
  const handleCacheControl = (url: string) => {
    if (url.match(/\.data/) || url.match(/\.wasm/)) {
      console.log(
        "[web-app] url matched data or bundle for cache must-revalidate: ",
        url,
      );
      return "must-revalidate";
    }
    if (url.match(/\.png/)) {
      return "immutable";
    }
    return "must-revalidate";
  };

  const {
    unityProvider: provider,
    sendMessage,
    isLoaded,
    addEventListener,
    removeEventListener,
    // https://github.com/jeffreylanters/react-unity-webgl/issues/22
    // it said that doing unload on window navigation causes Quit() not to be invoked correctly
    // react yanks canvas away so it never sees a canvas it needed to destroy
    UNSAFE__detachAndUnloadImmediate,
  } = useUnityContext({
    loaderUrl: `${PATH_TO_UNITY}/Calculon.loader.js`,
    dataUrl: `${PATH_TO_UNITY}/Calculon.data`,
    frameworkUrl: `${PATH_TO_UNITY}/Calculon.framework.js`,
    codeUrl: `${PATH_TO_UNITY}/Calculon.wasm`,
    cacheControl: handleCacheControl,
    webglContextAttributes: {
      alpha: true,
      antialias: true,
      depth: true,
      failIfMajorPerformanceCaveat: true,
      powerPreference: 2,
      premultipliedAlpha: true,
      // preserveDrawingBuffer: true,
      // stencil: true,
      // desynchronized: true,
      // xrCompatible: true,
    },
  });
  const detachAndUnloadRef = useRef(UNSAFE__detachAndUnloadImmediate);

  const handleInit = useCallback(() => {
    if (!currentPlayer) return;
    const payload: Record<string, unknown> = {
      all_levels_unlocked: unlockedNames,
      current_elo: currentPlayer.current_elo,
    };
    if (options.roomId) {
      payload.multiplayer = true;
      payload.questions = options.questions ?? [];
    }
    sendMessage(
      UNITY_GAME_OBJECT,
      UNITY_SEND_METHOD.GIVE_INITIAL_DATA,
      JSON.stringify(payload),
    );
  }, [
    sendMessage,
    currentPlayer,
    unlockedNames,
    options.roomId,
    options.questions,
  ]);

  const handleLevel = useCallback(
    (levelName: unknown) => {
      const level = levels.find((l) => l.name === levelName);

      // if game isnt a custom multiplayer game, validate
      if (levelName !== UNITY_CUSTOM_LEVEL) {
        if (!level) {
          toastError(`Sorry, ${levelName} isn't currently playable`);
          options.onCriticalError?.();
          return;
        }
        currentLevelIdRef.current = level.id;
      }

      currentScoreRef.current = 0;

      const startSession = async () => {
        const result = await dispatch(
          createGameSession({ level_id: level?.id, room_id: options.roomId }),
        );
        if (isFulfilled(createGameSession)(result)) {
          sessionIdRef.current = result.payload.id;
          lastAnswerAtRef.current = Date.now();
        } else {
          toastError(
            (result.payload as string) ?? "Could not start game session",
          );
          options.onCriticalError?.();
        }
      };
      startSession();
    },
    [dispatch, levels, options.roomId, options.onCriticalError],
  );

  const handleAnswer = useCallback(
    (correct: unknown) => {
      if (!sessionIdRef.current) return;
      const now = Date.now();
      const time_taken_ms =
        lastAnswerAtRef.current !== null
          ? now - lastAnswerAtRef.current
          : undefined;
      lastAnswerAtRef.current = now;
      const trackAnswer = async () => {
        const result = await dispatch(
          submitAnswer({
            sessionId: sessionIdRef.current!,
            is_correct: Boolean(correct),
            time_taken_ms,
          }),
        );
        if (isFulfilled(submitAnswer)(result)) {
          currentScoreRef.current = result.payload.current_score;
        } else {
          toastError("Sorry, we couldnt save your answer");
        }
      };
      trackAnswer();
    },
    [dispatch],
  );

  const handleFinished = useCallback(
    (alive: unknown) => {
      if (!sessionIdRef.current) return;
      const sessionId = sessionIdRef.current;
      sessionIdRef.current = null;
      const finishSession = async () => {
        const action = alive ? endGameSession : failGameSession;
        const result = await dispatch(action({ sessionId }));
        if (isFulfilled(action)(result)) {
          sendMessage(
            UNITY_GAME_OBJECT,
            UNITY_SEND_METHOD.FINALIZED,
            JSON.stringify(result.payload),
          );
          dispatch(getMe());
          options.onSessionFinished?.({
            elo_gained: result.payload.elo_gained,
            new_levels_unlocked: result.payload.new_levels_unlocked,
            levelId: currentLevelIdRef.current,
            score: currentScoreRef.current,
          });
        } else {
          toastError(
            (result.payload as string) ?? "Could not save your game result",
          );
        }
      };
      finishSession();
    },
    [dispatch, sendMessage, options.onSessionFinished],
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

  useEffect(() => {
    detachAndUnloadRef.current = UNSAFE__detachAndUnloadImmediate;
  }, [UNSAFE__detachAndUnloadImmediate]);

  useEffect(() => {
    return () => {
      detachAndUnloadRef.current().catch(() => {});
    };
  }, []);

  return {
    Unity,
    provider,
    isLoaded,
  };
}
