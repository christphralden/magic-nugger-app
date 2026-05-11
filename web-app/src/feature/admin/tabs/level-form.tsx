import { useForm } from "react-hook-form";
import { z } from "zod";
import { CartoonInput } from "@/components/ui/cartoon-input";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import type { RequestCreateLevel } from "@magic-nugger-app/shared";

const jsonString = z.string().refine(
  (v) => {
    try {
      JSON.parse(v);
      return true;
    } catch {
      return false;
    }
  },
  { message: "Invalid JSON" },
);

export const levelSchema = z.object({
  name: z.string().min(1, "Required"),
  description: z.string(),
  order_index: z.coerce.number().int().min(0, "Must be ≥ 0"),
  elo_min: z.coerce.number().int().min(0, "Must be ≥ 0"),
  elo_gain_correct: z.coerce.number().int().min(0, "Must be ≥ 0"),
  elo_loss_incorrect: z.coerce.number().int().min(0, "Must be ≥ 0"),
  time_limit_seconds: z.string(),
  max_score: z.coerce.number().int().min(0, "Must be ≥ 0"),
  enemy_wave_config: jsonString,
  question_gen_config: jsonString,
});

export type LevelFormValues = z.infer<typeof levelSchema>;

export const LEVEL_FORM_DEFAULTS: LevelFormValues = {
  name: "",
  description: "",
  order_index: "",
  elo_min: "0",
  elo_gain_correct: "15",
  elo_loss_incorrect: "5",
  time_limit_seconds: "",
  max_score: "1000",
  enemy_wave_config: JSON.stringify({ schema: 1, data: null }, null, 2),
  question_gen_config: JSON.stringify({ schema: 1, data: null }, null, 2),
} as unknown as LevelFormValues;

export function toRequestPayload(values: LevelFormValues): RequestCreateLevel {
  return {
    name: values.name,
    description: values.description || undefined,
    order_index: Number(values.order_index),
    elo_min: Number(values.elo_min),
    elo_gain_correct: Number(values.elo_gain_correct),
    elo_loss_incorrect: Number(values.elo_loss_incorrect),
    time_limit_seconds: values.time_limit_seconds
      ? Number(values.time_limit_seconds)
      : undefined,
    max_score: Number(values.max_score),
    enemy_wave_config: JSON.parse(values.enemy_wave_config),
    question_gen_config: JSON.parse(values.question_gen_config),
  };
}

export function LevelFields({
  form,
}: {
  form: ReturnType<typeof useForm<LevelFormValues>>;
}) {
  return (
    <Form {...form}>
      <div className="flex flex-col gap-3 [&_label]:font-body [&_p]:font-body">
        <div className="grid grid-cols-2 gap-3">
          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>Name</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput placeholder="Level name" {...field} />
                </FormControl>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="order_index"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>Order Index</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput type="number" placeholder="1" {...field} />
                </FormControl>
              </FormItem>
            )}
          />
        </div>
        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Description</FormLabel>
              <FormControl>
                <CartoonInput placeholder="Optional description" {...field} />
              </FormControl>
            </FormItem>
          )}
        />
        <div className="grid grid-cols-3 gap-3">
          <FormField
            control={form.control}
            name="elo_min"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>ELO Min</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput type="number" {...field} />
                </FormControl>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="elo_gain_correct"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>ELO Gain (correct)</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput type="number" {...field} />
                </FormControl>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="elo_loss_incorrect"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>ELO Loss (incorrect)</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput type="number" {...field} />
                </FormControl>
              </FormItem>
            )}
          />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <FormField
            control={form.control}
            name="time_limit_seconds"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Time Limit (seconds)</FormLabel>
                <FormControl>
                  <CartoonInput
                    type="number"
                    placeholder="Optional"
                    {...field}
                  />
                </FormControl>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="max_score"
            render={({ field }) => (
              <FormItem>
                <div className="flex gap-2 items-center">
                  <FormLabel>Max Score</FormLabel>
                  <FormMessage />
                </div>
                <FormControl>
                  <CartoonInput type="number" {...field} />
                </FormControl>
              </FormItem>
            )}
          />
        </div>
        <FormField
          control={form.control}
          name="enemy_wave_config"
          render={({ field }) => (
            <FormItem>
              <div className="flex gap-2 items-center">
                <FormLabel>Enemy Wave Config (JSON)</FormLabel>
                <FormMessage />
              </div>
              <FormControl>
                <textarea
                  className="w-full rounded-lg border-border border-[3px] p-2 font-mono min-h-[80px] resize-y focus:outline-none"
                  {...field}
                />
              </FormControl>
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="question_gen_config"
          render={({ field }) => (
            <FormItem>
              <div className="flex gap-2 items-center">
                <FormLabel>Question Gen Config (JSON)</FormLabel>
                <FormMessage />
              </div>
              <FormControl>
                <textarea
                  className="w-full rounded-lg border-border border-[3px] p-2 font-mono min-h-[80px] resize-y focus:outline-none"
                  {...field}
                />
              </FormControl>
            </FormItem>
          )}
        />
      </div>
    </Form>
  );
}
