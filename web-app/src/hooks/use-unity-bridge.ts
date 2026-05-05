import { useCallback } from "react";
import { Unity, useUnityContext } from "react-unity-webgl";

export function useUnityBridge() {
  const {
    unityProvider,
    sendMessage,
    isLoaded,
    addEventListener,
    removeEventListener,
  } = useUnityContext({
    loaderUrl: "/unity/build.loader.js",
    dataUrl: "/unity/build.data",
    frameworkUrl: "/unity/build.framework.js",
    codeUrl: "/unity/build.wasm",
  });

  const postAnswer = useCallback(
    (isCorrect: boolean, timeTakenMs: number) => {
      sendMessage(
        "GameManager",
        "ReceiveAnswer",
        JSON.stringify({ isCorrect, timeTakenMs }),
      );
    },
    [sendMessage],
  );

  return {
    unityProvider,
    isLoaded,
    postAnswer,
    addEventListener,
    removeEventListener,
    UnityComponent: Unity,
  };
}
