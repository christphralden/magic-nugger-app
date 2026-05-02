export async function tryCatch<T>(
  promise: Promise<T>,
): Promise<[null, T] | [Error, null]> {
  try {
    return [null, await promise];
  } catch (err) {
    return [err instanceof Error ? err : new Error(String(err)), null];
  }
}
