import { cva } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { CartoonInput } from "@/components/ui/cartoon-input";
import { Typography } from "@/components/ui/typography";
import {
  FormControl,
  FormField,
  FormItem,
  FormMessage,
} from "@/components/ui/form";
import { useFormContext } from "react-hook-form";
import type { Control, FieldErrors } from "react-hook-form";
import type { QuestionsFormValues } from "./questions-form";

const CHOICE_LABELS = ["A", "B", "C", "D"] as const;

const cardVariants = cva(
  "bg-white border-[3px] border-border rounded-xl shadow-cartoon-sm p-5 flex flex-col gap-4",
);

interface QuestionCardProps {
  index: number;
  control: Control<QuestionsFormValues>;
  errors: FieldErrors<QuestionsFormValues>;
  onRemove?: () => void;
  showRemove: boolean;
}

export function QuestionCard({ index, control, errors, onRemove, showRemove }: QuestionCardProps) {
  const { setValue } = useFormContext<QuestionsFormValues>();

  const handleSelectCorrect = (choiceIdx: number) => {
    for (let i = 0; i < 4; i++) {
      setValue(`questions.${index}.choices.${i}.is_correct`, i === choiceIdx, {
        shouldValidate: true,
      });
    }
  };

  return (
    <div className={cn(cardVariants())}>
      <div className="flex items-center justify-between">
        <Typography variant="label" as="span" className="text-ink-soft">
          Problem {index + 1}
        </Typography>
        {showRemove && (
          <button
            type="button"
            onClick={onRemove}
            className="text-coral font-display font-semibold text-sm hover:underline"
          >
            Remove
          </button>
        )}
      </div>

      <FormField
        control={control}
        name={`questions.${index}.question`}
        render={({ field }) => (
          <FormItem>
            <FormControl>
              <CartoonInput placeholder="Enter problem statement" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <div className="flex flex-col gap-2">
        {CHOICE_LABELS.map((label, choiceIdx) => (
          <div key={choiceIdx} className="flex items-center gap-3">
            <FormField
              control={control}
              name={`questions.${index}.choices.${choiceIdx}.is_correct`}
              render={({ field: radioField }) => (
                <button
                  type="button"
                  onClick={() => handleSelectCorrect(choiceIdx)}
                  className={cn(
                    "shrink-0 w-5 h-5 rounded-full border-[2.5px] border-border transition-all",
                    radioField.value
                      ? "bg-teal border-teal shadow-[0_0_0_2px_rgba(78,205,196,0.35)]"
                      : "bg-white hover:bg-cream",
                  )}
                  aria-label={`Mark choice ${label} as correct`}
                />
              )}
            />
            <Typography variant="label" as="span" className="shrink-0 w-5 text-center">
              {label}
            </Typography>
            <FormField
              control={control}
              name={`questions.${index}.choices.${choiceIdx}.text`}
              render={({ field }) => (
                <FormItem className="flex-1">
                  <FormControl>
                    <CartoonInput placeholder={`Choice ${label}`} {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>
        ))}
        {errors.questions?.[index]?.choices?.root && (
          <Typography variant="error" as="p" className="text-sm">
            {errors.questions[index].choices.root?.message}
          </Typography>
        )}
      </div>
    </div>
  );
}
