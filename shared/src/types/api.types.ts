import { z } from "zod";

export const ApiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    code: z.number().int(),
    error: z.string().nullable(),
    data: dataSchema,
  });

export type ApiResponse<T> = {
  code: number;
  error: string | null;
  data: T;
};
