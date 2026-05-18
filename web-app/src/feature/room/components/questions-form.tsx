import { useForm, useFieldArray } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { RequestSaveQuestionsSchema } from "@magic-nugger-app/shared";
import { Form } from "@/components/ui/form";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { QuestionCard } from "./question-card";
import { Plus } from "lucide-react";

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
  onSubmit: (values: QuestionsFormValues) => void;
  submitting: boolean;
}

export function QuestionsForm({ onSubmit, submitting }: QuestionsFormProps) {
  const form = useForm<QuestionsFormValues>({
    resolver: zodResolver(questionsFormSchema),
    defaultValues: {
      questions: [{ question: "", choices: DEFAULT_CHOICES }],
    },
  });

  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: "questions",
  });

  const handleAppend = () => {
    append({ question: "", choices: DEFAULT_CHOICES });
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-4">
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
          variant="secondary"
          size="default"
          onClick={handleAppend}
          className="w-full"
        >
          <Plus className="size-4 stroke-[3px]" />
          Add New Problem +
        </CartoonButton>

        <CartoonButton
          type="submit"
          variant="primary"
          size="lg"
          disabled={submitting}
          className="w-full"
        >
          {submitting ? "Saving..." : "Continue"}
        </CartoonButton>
      </form>
    </Form>
  );
}
