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
    dataUrl: `${PATH_TO_UNITY}/Calculon.data.br`,
    frameworkUrl: `${PATH_TO_UNITY}/Calculon.framework.js.br`,
    codeUrl: `${PATH_TO_UNITY}/Calculon.wasm.br`,
  });

  // const handleCommunicationTest = useCallback(
  //   (data: Object) => {
  //     sendMessage(
  //       "ReactUnityCommunication",
  //       "SpawnNiggers",
  //       JSON.stringify(data),
  //     );
  //   },
  //   [sendMessage],
  // );

  // const onReactMessage = useCallback((message: any, value: any) => {
  //   console.log(message, value);
  // }, []);
  //
  // useEffect(() => {
  //   addEventListener("ReactMessage", onReactMessage);
  //   return () => {
  //     removeEventListener("ReactMessage", onReactMessage);
  //   };
  // }, [addEventListener, removeEventListener, onReactMessage]);

  return {
    Unity: Unity,
    provider,
    isLoaded,
    addEventListener,
    removeEventListener,
  };
}
