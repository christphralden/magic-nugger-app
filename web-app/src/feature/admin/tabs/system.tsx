import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useDispatch, useSelector } from "@/store/hooks";
import {
  selectAdminLeaderboardCacheBust,
  selectAdminMemoryStats,
} from "@/feature/admin/state/admin.slice";
import {
  handleClearLeaderboardCacheAdmin,
  handleFetchMemoryStatsInternal,
} from "@/feature/admin/state/admin.actions";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CartoonInput } from "@/components/ui/cartoon-input";
import { Typography } from "@/components/ui/typography";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { CardSkeleton } from "@/feature/admin/components/card-skeleton";

const secretSchema = z.object({ secret: z.string().min(1, "Required") });
type SecretForm = z.infer<typeof secretSchema>;

export function SystemTab() {
  const dispatch = useDispatch();
  const cacheBust = useSelector(selectAdminLeaderboardCacheBust);
  const memoryStats = useSelector(selectAdminMemoryStats);

  const form = useForm<SecretForm>({
    resolver: zodResolver(secretSchema),
    defaultValues: { secret: "" },
  });

  const onSubmit = form.handleSubmit(async ({ secret }) => {
    await dispatch(handleFetchMemoryStatsInternal(secret));
  });

  return (
    <>
      <Typography as="h1" variant="subheading">
        System
      </Typography>

      <div className="rounded-xl flex gap-4 bg-white p-6 border-border border-[3px] shadow-cartoon-lg justify-between items-end">
        <div className="flex flex-col gap-2">
          <Typography variant="body" className="text-ink-soft">
            Leaderboard Cache
          </Typography>
          <Typography variant="caption" className="text-ink-soft">
            Clear the leaderboard cache to force fresh data on next request.
          </Typography>
        </div>
        <CartoonButton
          variant="primary"
          size={"sm"}
          className="w-fit font-body"
          disabled={cacheBust.status === "loading"}
          onClick={() => dispatch(handleClearLeaderboardCacheAdmin())}
        >
          {cacheBust.status === "loading" ? "Clearing..." : "Bust Cache"}
        </CartoonButton>
      </div>

      <div className="rounded-xl flex flex-col gap-4 bg-white p-6 border-border border-[3px] shadow-cartoon-lg">
        <Typography variant="body" className="text-ink-soft">
          Server Memory
        </Typography>
        <Form {...form}>
          <form onSubmit={onSubmit} className="flex flex-col gap-4 items-end">
            <FormField
              control={form.control}
              name="secret"
              render={({ field }) => (
                <FormItem className="w-full">
                  <div className="flex gap-2 items-center">
                    <FormLabel className="font-body">Internal Secret</FormLabel>
                    <FormMessage className="font-body" />
                  </div>
                  <FormControl>
                    <CartoonInput
                      type="password"
                      placeholder="Enter internal secret"
                      className="w-full"
                      {...field}
                    />
                  </FormControl>
                </FormItem>
              )}
            />
            <CartoonButton
              variant="select"
              type="submit"
              size={"sm"}
              className="font-body"
              disabled={memoryStats.status === "loading"}
            >
              {memoryStats.status === "loading"
                ? "Fetching..."
                : "Profile Memory"}
            </CartoonButton>
          </form>
        </Form>
        {memoryStats.status === "loading" && (
          <div className="mt-8">
            <CardSkeleton count={5} />
          </div>
        )}
        {memoryStats.data && (
          <div className="grid grid-cols-3 gap-4 mt-8">
            {[
              { label: "RSS", value: memoryStats.data.rss },
              { label: "Heap Total", value: memoryStats.data.heapTotal },
              { label: "Heap Used", value: memoryStats.data.heapUsed },
              { label: "External", value: memoryStats.data.external },
              { label: "Array Buffers", value: memoryStats.data.arrayBuffers },
            ].map(({ label, value }) => (
              <div
                key={label}
                className="flex flex-col gap-1 rounded-lg bg-white p-4 border-border border-[3px] shadow-cartoon-sm"
              >
                <Typography variant="body" className="text-ink-soft">
                  {label}
                </Typography>
                <Typography variant="body" className="!text-2xl">
                  {value}
                </Typography>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}
