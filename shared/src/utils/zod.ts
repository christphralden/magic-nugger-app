import { ZodSchema } from "zod";
import zodToJsonSchema from "zod-to-json-schema";

export const jzod = <T>(schema: ZodSchema<T>) => {
  const json = zodToJsonSchema(schema, { name: "schema", errorMessages: true });
  return json.definitions?.["schema"];
};
