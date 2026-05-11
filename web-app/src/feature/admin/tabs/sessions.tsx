import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectAdminSessions } from "@/feature/admin/state/admin.slice";
import {
  handleFetchSessionsAdmin,
  handleApplySessionFilters,
} from "@/feature/admin/state/admin.actions";
import { useCursor } from "@/hooks/use-cursor";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CartoonInput } from "@/components/ui/cartoon-input";
import { CartoonSelect } from "@/components/ui/cartoon-select";
import { Typography } from "@/components/ui/typography";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { cn } from "@/lib/utils";
const SESSION_STATUS_OPTIONS = [
  { value: "all", label: "All statuses" },
  { value: "in_progress", label: "In Progress" },
  { value: "completed", label: "Completed" },
  { value: "failed", label: "Failed" },
  { value: "abandoned", label: "Abandoned" },
] as const;

const filterSchema = z.object({
  player_id: z.string(),
  level_id: z.string(),
  status: z.string(),
});
type FilterForm = z.infer<typeof filterSchema>;

export function SessionsTab() {
  const dispatch = useDispatch();
  const { items, next_cursor, status } = useSelector(selectAdminSessions);
  const cursor = useCursor();

  const form = useForm<FilterForm>({
    resolver: zodResolver(filterSchema),
    defaultValues: { player_id: "", level_id: "", status: "all" },
  });

  useEffect(() => {
    dispatch(handleFetchSessionsAdmin({ cursor: cursor.current }));
  }, [dispatch, cursor.current]);

  const onApplyFilters = form.handleSubmit((values) => {
    cursor.reset();
    dispatch(
      handleApplySessionFilters({
        player_id: values.player_id,
        level_id: values.level_id,
        status: values.status,
      }),
    );
  });

  return (
    <>
      <Typography as="h1" variant="subheading">
        Sessions
      </Typography>

      <div className="rounded-xl flex flex-col gap-0 bg-white p-6 border-border border-[3px] shadow-cartoon-lg">
        <form onSubmit={onApplyFilters}>
          <div className="grid grid-cols-3 gap-4 mb-4">
            <div className="flex flex-col gap-1">
              <Typography variant="body">Player ID</Typography>
              <CartoonInput
                placeholder="UUID..."
                {...form.register("player_id")}
              />
            </div>
            <div className="flex flex-col gap-1">
              <Typography variant="body">Level ID</Typography>
              <CartoonInput
                placeholder="Level number..."
                {...form.register("level_id")}
              />
            </div>
            <div className="flex flex-col gap-1">
              <Typography variant="body">Status</Typography>
              <CartoonSelect
                options={SESSION_STATUS_OPTIONS}
                value={form.watch("status")}
                onValueChange={(v) => form.setValue("status", v)}
                placeholder="All statuses"
              />
            </div>
          </div>
          <div className="w-full flex justify-end">
            <CartoonButton
              variant="select"
              size={"sm"}
              type="submit"
              className="w-fit font-body"
              disabled={status === "loading"}
            >
              Apply Filters
            </CartoonButton>
          </div>
        </form>
      </div>

      <div className="rounded-xl flex flex-col gap-0 bg-white border-border border-[3px] shadow-cartoon-lg overflow-hidden">
        {status === "loading" && items.length === 0 && (
          <div className="p-6">
            <Typography variant="body" className="text-ink-soft">
              Loading...
            </Typography>
          </div>
        )}
        {status === "succeeded" && items.length === 0 && (
          <div className="p-6">
            <Typography variant="body" className="text-ink-soft">
              No sessions found
            </Typography>
          </div>
        )}
        {items.length > 0 && (
          <ScrollArea className="h-[53.75dvh]">
            <Table>
              <TableHeader>
                <TableRow header>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      ID
                    </Typography>
                  </TableHead>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      Player
                    </Typography>
                  </TableHead>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      Level
                    </Typography>
                  </TableHead>
                  <TableHead className="text-right">
                    <Typography variant="body" className="text-ink-soft">
                      Score
                    </Typography>
                  </TableHead>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      Date
                    </Typography>
                  </TableHead>
                  <TableHead className="text-right">
                    <Typography variant="body" className="text-ink-soft">
                      Status
                    </Typography>
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody className={cn(status === "loading" && "opacity-50")}>
                {items.map((session) => (
                  <TableRow key={session.id}>
                    <TableCell>
                      <Typography variant="body">{session.id}</Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body">
                        {session.player_id}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body">{session.level_id}</Typography>
                    </TableCell>
                    <TableCell className="text-right">
                      <Typography variant="body">{session.score}</Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body">
                        {new Date(session.started_at).toLocaleDateString()}
                      </Typography>
                    </TableCell>
                    <TableCell className="text-right">
                      <Typography variant="body">{session.status}</Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </ScrollArea>
        )}
      </div>

      <div className="flex items-center justify-between">
        <Typography variant="body" className="text-ink-soft">
          Page {cursor.pageIndex + 1}
        </Typography>
        <div className="flex gap-2">
          <CartoonButton
            variant="secondary"
            size="default"
            onClick={cursor.prev}
            disabled={!cursor.hasPrev}
            className="!px-4 !py-3 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <ChevronLeft className="size-5" />
          </CartoonButton>
          <CartoonButton
            variant="secondary"
            size="default"
            onClick={() => next_cursor && cursor.next(next_cursor)}
            disabled={next_cursor === null}
            className="!px-4 !py-3 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <ChevronRight className="size-5" />
          </CartoonButton>
        </div>
      </div>
    </>
  );
}
