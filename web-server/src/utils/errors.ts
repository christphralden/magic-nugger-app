export const formatError = (error: unknown) => {
  let content = [];
  if (error instanceof Error) {
    content.push(error.message.trim());
    if (error.stack) {
      const trace =
        error.stack
          ?.split("\n")
          .slice(0, 2)
          .filter((v) => Boolean(v))
          .map((v) => v.trim()) || [];
      content.push(...trace);
    }
  } else {
    content.push("You are beyond fucked");
  }

  return content.join("\n");
};

export const isPgError = (error: unknown): error is Error & { code: string } =>
  error instanceof Error &&
  "code" in error &&
  typeof (error as any).code === "string";
