import { useEffect } from "react";
import { useDispatch, useSelector } from "@/store/hooks";
import {
  selectAdminStats,
  selectAdminStatsStatus,
  selectAdminActiveSessions,
} from "@/feature/admin/state/admin.slice";
import {
  handleGetStatsAdmin,
  handleGetActiveSessionsAdmin,
} from "@/feature/admin/state/admin.actions";
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
import { CardSkeleton } from "@/feature/admin/components/card-skeleton";
import { Loader2 } from "lucide-react";

export function DashboardTab() {
  const dispatch = useDispatch();
  const stats = useSelector(selectAdminStats);
  const statsStatus = useSelector(selectAdminStatsStatus);
  const { items: activeSessions, status: activeSessionsStatus } = useSelector(
    selectAdminActiveSessions,
  );

  useEffect(() => {
    dispatch(handleGetStatsAdmin());
    dispatch(handleGetActiveSessionsAdmin());
  }, [dispatch]);

  return (
    <>
      <Typography as="h1" variant="subheading">
        Dashboard
      </Typography>

      <div className="rounded-xl flex flex-col gap-4">
        {statsStatus === "loading" && !stats && <CardSkeleton count={3} />}
        {stats && (
          <div className="grid grid-cols-3 gap-4">
            {[
              { label: "Total players", value: stats.total_players },
              { label: "Total sessions", value: stats.total_sessions },
              { label: "Completed sessions", value: stats.completed_sessions },
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

      <div className="rounded-xl flex flex-col gap-0 bg-white border-border border-[3px] shadow-cartoon-lg overflow-hidden">
        <ScrollArea className="h-[480px]">
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
                <TableHead className="text-right">
                  <Typography variant="body" className="text-ink-soft">
                    Status
                  </Typography>
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {activeSessions.map((session) => (
                <TableRow key={session.id}>
                  <TableCell>
                    <Typography variant="body">{session.id}</Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body">{session.player_id}</Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body">{session.level_id}</Typography>
                  </TableCell>
                  <TableCell className="text-right">
                    <Typography variant="body">{session.score}</Typography>
                  </TableCell>
                  <TableCell className="text-right">
                    <Typography variant="body">{session.status}</Typography>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
            {activeSessionsStatus === "loading" && (
              <TableRow>
                <TableCell colSpan={5}>
                  <Loader2 className="animate-spin mx-auto" />
                </TableCell>
              </TableRow>
            )}
          </Table>
        </ScrollArea>
      </div>
    </>
  );
}
