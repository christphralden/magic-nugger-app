import { PATH_TO_UNITY } from "@/constants";
import { useCallback, useEffect } from "react";
import { Unity, useUnityContext } from "react-unity-webgl";

export function useUnityBridge() {
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

  const cb = (...args: any) => {
    console.log(args);
  };

  useEffect(() => {
    addEventListener("ReactMessage", cb);
    return () => {
      removeEventListener("ReactMessage", cb);
    };
  }, [addEventListener, removeEventListener, cb]);

  return {
    Unity: Unity,
    provider,
    isLoaded,
    addEventListener,
    removeEventListener,
    handleCommunicationTest,
  };
}
