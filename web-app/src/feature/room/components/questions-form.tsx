import { useEffect } from "react";
import { useForm, useFieldArray } from "react-hook-form";
import { useBlocker } from "react-router-dom";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { RequestSaveQuestionsSchema } from "@magic-nugger-app/shared";
import { Form } from "@/components/ui/form";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { ConfirmLeaveDialog } from "@/components/ui/confirm-leave-dialog";
import { QuestionCard } from "./question-card";
import { Plus } from "lucide-react";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";

const questionsFormSchema = RequestSaveQuestionsSchema.extend({
  questions: z
    .array(
      z.object({
        question: z.string().min(1, "Problem is required"),
        choices: z
          .array(
            z.object({
              text: z.string().min(1, "Choice text is required"),
              is_correct: z.boolean(),
            }),
          )
          .length(4)
          .refine(
            (choices) => choices.filter((c) => c.is_correct).length === 1,
            { message: "Select exactly one correct answer" },
          ),
      }),
    )
    .min(1, "Add at least one question"),
});

export type QuestionsFormValues = z.infer<typeof questionsFormSchema>;

const DEFAULT_CHOICES = [
  { text: "", is_correct: false },
  { text: "", is_correct: false },
  { text: "", is_correct: false },
  { text: "", is_correct: false },
];

interface QuestionsFormProps {
  roomId: string;
  onSubmit: (values: QuestionsFormValues) => Promise<boolean>;
  onOpenRoom: () => void;
  submitting: boolean;
  opening: boolean;
  hasExistingQuestions: boolean;
  defaultValues?: QuestionsFormValues;
}

export function QuestionsForm({
  roomId,
  onSubmit,
  onOpenRoom,
  submitting,
  opening,
  hasExistingQuestions,
  defaultValues,
}: QuestionsFormProps) {
  const form = useForm<QuestionsFormValues>({
    resolver: zodResolver(questionsFormSchema),
    defaultValues: defaultValues ?? {
      questions: [{ question: "", choices: DEFAULT_CHOICES }],
    },
  });

  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: "questions",
  });

  const { isDirty } = form.formState;

  useEffect(() => {
    const handleBeforeUnload = () => {
      if (!isDirty) return;
      const values = form.getValues();
      fetch(`${WEB_SERVER_URL}/${API_VERSION_BASE}/rooms/${roomId}/questions`, {
        method: "PUT",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ questions: values.questions }),
        keepalive: true,
      });
    };
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [roomId, isDirty]);

  const blocker = useBlocker(({ currentLocation, nextLocation }) => {
    if (currentLocation.pathname === nextLocation.pathname) return false;
    return isDirty;
  });

  const handleAppend = () => {
    append({ question: "", choices: DEFAULT_CHOICES });
  };

  const handleSave = async (values: QuestionsFormValues) => {
    const success = await onSubmit(values);
    if (success) form.reset(values);
  };

  const isDisabled =
    (!isDirty && !hasExistingQuestions) || submitting || opening;

  const buttonLabel = isDirty
    ? submitting
      ? "Saving..."
      : "Save Questions"
    : opening
      ? "Opening..."
      : "Open Room";

  const handleAction = isDirty ? form.handleSubmit(handleSave) : onOpenRoom;

  return (
    <>
      {blocker.state === "blocked" && (
        <ConfirmLeaveDialog
          title="Leave without saving?"
          description="Your unsaved questions will be lost."
          onConfirm={() => blocker.proceed?.()}
          onCancel={() => blocker.reset?.()}
        />
      )}
      <Form {...form}>
        <form className="flex flex-col gap-4 w-full h-full">
          {fields.map((field, index) => (
            <QuestionCard
              key={field.id}
              index={index}
              control={form.control}
              errors={form.formState.errors}
              showRemove={fields.length > 1}
              onRemove={() => remove(index)}
            />
          ))}

          <CartoonButton
            type="button"
            variant="ghost"
            size="sm"
            onClick={handleAppend}
            className="w-fit mx-auto"
          >
            <Plus className="size-4 stroke-[4px]" />
            Add new problem
          </CartoonButton>

          <CartoonButton
            type="button"
            variant="primary"
            disabled={isDisabled}
            onClick={handleAction}
            className="w-full mt-16"
          >
            {buttonLabel}
          </CartoonButton>
        </form>
      </Form>
    </>
  );
}
