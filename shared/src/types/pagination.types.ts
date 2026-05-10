export type CursorPagination = {
  cursor?: number;
  limit: number;
};

export type PaginatedData<T> = {
  items: T[];
  next_cursor: number | null;
};
