import { Skeleton } from "@/components/ui/skeleton";

export function LevelCardSkeleton() {
  return (
    <div className="bg-paper border-[3px] border-border rounded-md shadow-cartoon p-6">
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1 min-w-0 flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <Skeleton className="h-5 w-32" />
            <Skeleton className="h-5 w-12" />
          </div>
          <Skeleton className="h-4 w-3/4" />
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <Skeleton className="h-9 w-28" />
          <Skeleton className="h-9 w-16" />
        </div>
      </div>
    </div>
  );
}
