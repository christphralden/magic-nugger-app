// import { useSearchParams } from "react-router-dom";
import { FloatingText } from "@/components/floating-text";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { useUnityBridge } from "@/hooks/use-unity-bridge";
import { useRef } from "react";

export function GamePage() {
  // const [searchParams] = useSearchParams();
  const { Unity, provider, isLoaded, handleCommunicationTest } =
    useUnityBridge();

  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  return (
    <PageLayout title="Game">
      <div className="absolute">
        {!isLoaded && (
          <div className="w-full h-full flex justify-center items-center">
            <Typography variant={"heading"}>
              <FloatingText text="Loading your nuggers..." duration={1} />
            </Typography>
          </div>
        )}
      </div>
      <div className="flex justify-center w-full h-full items-center">
        <Unity
          unityProvider={provider}
          className="w-full h-full"
          ref={canvasRef}
        />
        <div className="absolute bg-blue-200 top-0 left-0 w-[100vw] h-[100vh] relative">
          <CartoonButton
            className="absolute bottom-[100px] right-[100px]"
            onClick={() => {
              handleCommunicationTest("Niggersss");
            }}
          >
            Nigger Button
          </CartoonButton>
        </div>
      </div>
    </PageLayout>
  );
}
