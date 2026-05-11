import { useSearchParams } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { useUnityBridge } from "@/hooks/use-unity-bridge";

export function GamePage() {
  const [searchParams] = useSearchParams();
  const {
    Unity,
    provider,
    isLoaded,
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
