import { cn } from "@/lib/utils";
import Cloud1 from "@/assets/cloud-1.png";
import Cloud2 from "@/assets/cloud-2.png";
import Cloud3 from "@/assets/cloud-3.png";
import Cloud4 from "@/assets/cloud-4.png";
import Cloud5 from "@/assets/cloud-5.png";
import Cloud6 from "@/assets/cloud-6.png";

const cloudMap: Record<string, string> = {
  "1": Cloud1,
  "2": Cloud2,
  "3": Cloud3,
  "4": Cloud4,
  "5": Cloud5,
  "6": Cloud6,
};

export function CloudPixel({
  className,
  variant = "1",
}: {
  className?: string;
  variant?: "1" | "2" | "3" | "4" | "5" | "6";
}) {
  return (
    <img src={cloudMap[variant]} alt="cloud" className={cn("aspect-auto", className)} />
  );
}
