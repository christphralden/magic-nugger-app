export type CursorPagination = {
  cursor?: string;
  limit: number;
};

export type PaginatedData<T> = {
  items: T[];
  next_cursor: string | null;
};
