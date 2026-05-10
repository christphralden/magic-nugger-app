import { Button } from "@/components/ui/button";
import { useUnityBridge } from "@/hooks/use-unity-bridge";

export function GamePage() {
  const {
    Unity,
    provider,
    isLoaded,
    addEventListener,
    removeEventListener,
    handleCommunicationTest,
  } = useUnityBridge();

  return (
    <div className="flex min-h-screen items-center justify-center">
      <h1 className="text-2xl font-bold">Game</h1>
      <Unity unityProvider={provider} />

      <Button
        onClick={() => {
          if (!isLoaded) {
            alert("retard");
            return;
          }
          handleCommunicationTest({ shawn: "nigger" });
        }}
      >
        Test
      </Button>
    </div>
  );
}
