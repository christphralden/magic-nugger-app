import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectAdminPlayers } from "@/feature/admin/state/admin.slice";
import {
  handleFetchPlayersAdmin,
  handleAdjustPlayerEloAdmin,
  handleAdjustPlayerRoleAdmin,
} from "@/feature/admin/state/admin.actions";
import { useCursor } from "@/hooks/use-cursor";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { CartoonInput } from "@/components/ui/cartoon-input";
import { Typography } from "@/components/ui/typography";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";

const eloSchema = z.object({
  elo: z.coerce.number().int().min(0, "Must be ≥ 0"),
});
const roleSchema = z.object({ role: z.string().min(1, "Required") });
type EloForm = z.infer<typeof eloSchema>;
type RoleForm = z.infer<typeof roleSchema>;

type ActiveEdit = { id: string; type: "elo" | "role" } | null;

export function PlayersTab() {
  const dispatch = useDispatch();
  const { items, next_cursor, status } = useSelector(selectAdminPlayers);
  const cursor = useCursor();

  const [activeEdit, setActiveEdit] = useState<ActiveEdit>(null);

  const eloForm = useForm<EloForm>({ resolver: zodResolver(eloSchema) });
  const roleForm = useForm<RoleForm>({ resolver: zodResolver(roleSchema) });

  useEffect(() => {
    dispatch(handleFetchPlayersAdmin({ cursor: cursor.current }));
  }, [dispatch, cursor.current]);

  const openEdit = (id: string, type: "elo" | "role", current: string) => {
    setActiveEdit({ id, type });
    if (type === "elo") eloForm.reset({ elo: Number(current) });
    else roleForm.reset({ role: current });
  };

  const closeEdit = () => setActiveEdit(null);

  const onSubmitElo = eloForm.handleSubmit(async ({ elo }) => {
    if (!activeEdit) return;
    const ok = await dispatch(handleAdjustPlayerEloAdmin(activeEdit.id, elo));
    if (ok) closeEdit();
  });

  const onSubmitRole = roleForm.handleSubmit(async ({ role }) => {
    if (!activeEdit) return;
    const ok = await dispatch(handleAdjustPlayerRoleAdmin(activeEdit.id, role));
    if (ok) closeEdit();
  });

  return (
    <>
      <Typography as="h1" variant="subheading">
        Players
      </Typography>

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
              No players found
            </Typography>
          </div>
        )}
        {items.length > 0 && (
          <ScrollArea className="h-[75dvh]">
            <Table>
              <TableHeader>
                <TableRow header>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      Username
                    </Typography>
                  </TableHead>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      Email
                    </Typography>
                  </TableHead>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      Role
                    </Typography>
                  </TableHead>
                  <TableHead className="text-right">
                    <Typography variant="body" className="text-ink-soft">
                      ELO
                    </Typography>
                  </TableHead>
                  <TableHead>
                    <Typography variant="body" className="text-ink-soft">
                      Joined
                    </Typography>
                  </TableHead>
                  <TableHead className="text-right">
                    <Typography variant="body" className="text-ink-soft px-2">
                      Actions
                    </Typography>
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((player) => (
                  <>
                    <TableRow key={player.id} className="h-16">
                      <TableCell>
                        <Typography variant="body">
                          {player.username}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body">{player.email}</Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body">
                          {player.role_name}
                        </Typography>
                      </TableCell>
                      <TableCell className="text-right">
                        <Typography variant="body">
                          {player.current_elo}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body">
                          {new Date(player.created_at).toLocaleDateString()}
                        </Typography>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex gap-2 justify-end">
                          <CartoonButton
                            variant="select"
                            size={"sm"}
                            className="font-body"
                            disabled={Boolean(
                              activeEdit?.id && activeEdit?.id != player.id,
                            )}
                            onClick={() =>
                              openEdit(
                                player.id,
                                "elo",
                                String(player.current_elo),
                              )
                            }
                          >
                            ELO
                          </CartoonButton>
                          <CartoonButton
                            variant="select"
                            size={"sm"}
                            className="font-body"
                            disabled={Boolean(
                              activeEdit?.id && activeEdit?.id != player.id,
                            )}
                            onClick={() =>
                              openEdit(player.id, "role", player.role_name)
                            }
                          >
                            Role
                          </CartoonButton>
                        </div>
                      </TableCell>
                    </TableRow>
                    {activeEdit?.id === player.id && (
                      <TableRow className="bg-gray-50 border-b border-border">
                        <TableCell colSpan={6}>
                          {activeEdit.type === "elo" ? (
                            <Form {...eloForm}>
                              <form
                                onSubmit={onSubmitElo}
                                className="flex items-end gap-2 justify-end"
                              >
                                <FormField
                                  control={eloForm.control}
                                  name="elo"
                                  render={({ field }) => (
                                    <FormItem>
                                      <FormLabel>Elo</FormLabel>
                                      <FormControl>
                                        <CartoonInput
                                          type="number"
                                          placeholder="New ELO value"
                                          className="!py-2 !text-sm"
                                          {...field}
                                        />
                                      </FormControl>
                                      <FormMessage className="font-body" />
                                    </FormItem>
                                  )}
                                />
                                <CartoonButton
                                  variant="primary"
                                  size={"sm"}
                                  type="submit"
                                  className="font-body"
                                  disabled={eloForm.formState.isSubmitting}
                                >
                                  {eloForm.formState.isSubmitting
                                    ? "Saving..."
                                    : "Save"}
                                </CartoonButton>
                                <CartoonButton
                                  variant="secondary"
                                  type="button"
                                  size={"sm"}
                                  className="font-body"
                                  onClick={closeEdit}
                                >
                                  Cancel
                                </CartoonButton>
                              </form>
                            </Form>
                          ) : (
                            <Form {...roleForm}>
                              <form
                                onSubmit={onSubmitRole}
                                className="flex items-end gap-2 justify-end"
                              >
                                <FormField
                                  control={roleForm.control}
                                  name="role"
                                  render={({ field }) => (
                                    <FormItem>
                                      <FormLabel>Role</FormLabel>
                                      <FormControl>
                                        <CartoonInput
                                          placeholder="Role name"
                                          className="!py-2 !text-sm"
                                          {...field}
                                        />
                                      </FormControl>
                                      <FormMessage className="font-body" />
                                    </FormItem>
                                  )}
                                />
                                <CartoonButton
                                  variant="primary"
                                  type="submit"
                                  size={"sm"}
                                  className="font-body"
                                  disabled={roleForm.formState.isSubmitting}
                                >
                                  {roleForm.formState.isSubmitting
                                    ? "Saving..."
                                    : "Save"}
                                </CartoonButton>
                                <CartoonButton
                                  variant="secondary"
                                  type="button"
                                  size={"sm"}
                                  className="font-body"
                                  onClick={closeEdit}
                                >
                                  Cancel
                                </CartoonButton>
                              </form>
                            </Form>
                          )}
                        </TableCell>
                      </TableRow>
                    )}
                  </>
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
