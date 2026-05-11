import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useDispatch, useSelector } from "@/store/hooks";
import {
  selectAdminLevels,
  selectAdminSelectedLevel,
} from "@/feature/admin/state/admin.slice";
import {
  handleFetchLevelsAdmin,
  handleFetchLevelAdmin,
  handleUpdateLevelAdmin,
  handleActivateLevelAdmin,
  handleDeleteLevelAdmin,
} from "@/feature/admin/state/admin.actions";
import { CartoonButton } from "@/components/ui/cartoon-button";
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
import { TableSkeleton } from "@/feature/admin/components/table-skeleton";
import type { RequestUpdateLevel } from "@magic-nugger-app/shared";
import {
  levelSchema,
  LevelFormValues,
  LEVEL_FORM_DEFAULTS,
  toRequestPayload,
  LevelFields,
} from "@/feature/admin/tabs/level-form";

export function LevelsTab() {
  const dispatch = useDispatch();
  const { items, status } = useSelector(selectAdminLevels);
  const selectedLevel = useSelector(selectAdminSelectedLevel);

  const [expandedId, setExpandedId] = useState<number | null>(null);
  const [editLoading, setEditLoading] = useState(false);

  const editForm = useForm<LevelFormValues>({
    resolver: zodResolver(levelSchema),
    defaultValues: LEVEL_FORM_DEFAULTS,
  });

  useEffect(() => {
    dispatch(handleFetchLevelsAdmin());
  }, [dispatch]);

  useEffect(() => {
    if (selectedLevel.data && selectedLevel.data.id === expandedId) {
      const l = selectedLevel.data;
      editForm.reset({
        name: l.name,
        description: l.description ?? "",
        order_index: String(l.order_index) as unknown as number,
        elo_min: String(l.elo_min) as unknown as number,
        elo_gain_correct: String(l.elo_gain_correct) as unknown as number,
        elo_loss_incorrect: String(l.elo_loss_incorrect) as unknown as number,
        time_limit_seconds:
          l.time_limit_seconds != null ? String(l.time_limit_seconds) : "",
        max_score: String(l.max_score) as unknown as number,
        enemy_wave_config: JSON.stringify(l.enemy_wave_config, null, 2),
        question_gen_config: JSON.stringify(l.question_gen_config, null, 2),
      });
    }
  }, [selectedLevel.data, expandedId]);

  const handleExpand = (id: number) => {
    if (expandedId === id) {
      setExpandedId(null);
      return;
    }
    setExpandedId(id);
    dispatch(handleFetchLevelAdmin(id));
  };

  const onSubmitEdit = editForm.handleSubmit(async (values) => {
    if (expandedId === null) return;
    const payload: RequestUpdateLevel = { ...toRequestPayload(values) };
    await dispatch(handleUpdateLevelAdmin(expandedId, payload));
  });

  const handleToggleActive = async (id: number, current: boolean) => {
    setEditLoading(true);
    await dispatch(handleActivateLevelAdmin(id, !current));
    setEditLoading(false);
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm("Delete this level? This cannot be undone.")) return;
    await dispatch(handleDeleteLevelAdmin(id));
    if (expandedId === id) setExpandedId(null);
  };

  return (
    <>
      <Typography as="h1" variant="subheading">
        Levels
      </Typography>

      <div className="rounded-xl flex flex-col gap-0 bg-white border-border border-[3px] shadow-cartoon-lg overflow-hidden">
        <ScrollArea className="h-[75vh]">
          <Table>
            <TableHeader>
              <TableRow header>
                <TableHead className="w-12">
                  <Typography variant="body" className="text-ink-soft">
                    #
                  </Typography>
                </TableHead>
                <TableHead className="w-12">
                  <Typography variant="body" className="text-ink-soft">
                    ID
                  </Typography>
                </TableHead>

                <TableHead>
                  <Typography variant="body" className="text-ink-soft">
                    Name
                  </Typography>
                </TableHead>
                <TableHead className="text-right">
                  <Typography variant="body" className="text-ink-soft">
                    ELO Min
                  </Typography>
                </TableHead>
                <TableHead className="text-center">
                  <Typography variant="body" className="text-ink-soft">
                    Status
                  </Typography>
                </TableHead>
                <TableHead className="text-right">
                  <Typography variant="body" className="text-ink-soft px-4">
                    Actions
                  </Typography>
                </TableHead>
              </TableRow>
            </TableHeader>
            {status === "loading" && items.length === 0 ? (
              <TableSkeleton cols={5} />
            ) : (
              <TableBody>
                {items.map((level) => (
                  <>
                    <TableRow key={level.id}>
                      <TableCell>
                        <Typography variant="body" className="text-ink-soft">
                          {level.order_index}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body" className="text-ink-soft">
                          {level.id}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-col gap-0">
                          <Typography variant="body">{level.name}</Typography>
                          {level.description && (
                            <Typography
                              variant="caption"
                              className="line-clamp-1"
                            >
                              {level.description}
                            </Typography>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="text-right">
                        <Typography variant="body" className="text-ink-soft">
                          {level.elo_min}
                        </Typography>
                      </TableCell>
                      <TableCell className="text-center">
                        <Typography variant={"body"}>
                          {level.is_active ? "active" : "inactive"}
                        </Typography>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex gap-2 justify-end">
                          <CartoonButton
                            variant={"select"}
                            size={"sm"}
                            className="font-body"
                            disabled={Boolean(
                              expandedId && expandedId !== level.id,
                            )}
                            onClick={() => handleExpand(level.id)}
                          >
                            {expandedId === level.id ? "Close" : "Edit"}
                          </CartoonButton>
                          <CartoonButton
                            variant="secondary"
                            size={"sm"}
                            className="font-body"
                            disabled={Boolean(
                              expandedId && expandedId !== level.id,
                            )}
                            onClick={() => handleDelete(level.id)}
                          >
                            Delete
                          </CartoonButton>
                        </div>
                      </TableCell>
                    </TableRow>
                    {expandedId === level.id && (
                      <TableRow className="border-b border-border">
                        <TableCell colSpan={5} className="bg-gray-50">
                          {selectedLevel.status !== "loading" &&
                            selectedLevel.data?.id === level.id && (
                              <form
                                onSubmit={onSubmitEdit}
                                className="flex flex-col gap-4 py-4"
                              >
                                <LevelFields form={editForm} />
                                <div className="flex gap-2 w-full justify-end">
                                  <CartoonButton
                                    variant="primary"
                                    size={"sm"}
                                    type="submit"
                                    className="font-body"
                                    disabled={
                                      editForm.formState.isSubmitting ||
                                      editLoading
                                    }
                                  >
                                    {editForm.formState.isSubmitting
                                      ? "Saving..."
                                      : "Save Changes"}
                                  </CartoonButton>
                                  <CartoonButton
                                    variant="secondary"
                                    size={"sm"}
                                    type="button"
                                    className="font-body"
                                    disabled={editLoading}
                                    onClick={() =>
                                      handleToggleActive(
                                        level.id,
                                        level.is_active,
                                      )
                                    }
                                  >
                                    {level.is_active
                                      ? "Deactivate"
                                      : "Activate"}
                                  </CartoonButton>
                                </div>
                              </form>
                            )}
                        </TableCell>
                      </TableRow>
                    )}
                  </>
                ))}
              </TableBody>
            )}
          </Table>
        </ScrollArea>
      </div>
    </>
  );
}
