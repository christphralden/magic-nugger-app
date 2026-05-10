import { z } from "zod";

export function JSONBSchema<T extends z.ZodTypeAny>(dataSchema: T) {
  return z.object({
    schema: z.number(),
    data: dataSchema,
  });
}

export type JSONB<T> = {
  schema: number;
  data: T;
};
