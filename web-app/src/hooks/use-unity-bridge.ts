import { useCallback } from "react";
import { Unity, useUnityContext } from "react-unity-webgl";

export function useUnityBridge() {
  const {
    unityProvider: provider,
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

  const handleCommunicationTest = useCallback(
    (data: Object) => {
      sendMessage(
        "ReactUnityCommunication",
        "SpawnNiggers",
        JSON.stringify(data),
      );
    },
    [sendMessage],
  );

  return {
    Unity: Unity,
    provider,
    isLoaded,
    addEventListener,
    removeEventListener,
    handleCommunicationTest,
  };
}
