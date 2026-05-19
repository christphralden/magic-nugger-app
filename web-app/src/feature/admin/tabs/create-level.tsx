import { useNavigate } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useDispatch } from "@/store/hooks";
import { handleCreateLevelAdmin } from "@/feature/admin/state/admin.actions";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import {
  levelSchema,
  LevelFormValues,
  LEVEL_FORM_DEFAULTS,
  toRequestPayload,
  LevelFields,
} from "@/feature/admin/tabs/level-form";

export function CreateLevelTab() {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const form = useForm<LevelFormValues>({
    resolver: zodResolver(levelSchema),
    defaultValues: LEVEL_FORM_DEFAULTS,
  });

  const onSubmit = form.handleSubmit(async (values) => {
    const ok = await dispatch(handleCreateLevelAdmin(toRequestPayload(values)));
    if (ok) navigate("/admin/levels");
  });

  return (
    <>
      <Typography as="h1" variant="subheading">
        Create Level
      </Typography>

      <div className="rounded-xl flex flex-col gap-4 bg-white p-6 border-border border-[3px] shadow-cartoon-lg">
        <form onSubmit={onSubmit} className="flex flex-col gap-4">
          <LevelFields form={form} />
          <div className="flex gap-2 justify-end w-full">
            <CartoonButton
              variant="primary"
              type="submit"
              className="font-body"
              size={"sm"}
              disabled={form.formState.isSubmitting}
            >
              {form.formState.isSubmitting ? "Creating..." : "Create"}
            </CartoonButton>
          </div>
        </form>
      </div>
    </>
  );
}
