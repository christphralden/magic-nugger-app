export const HttpCode = {
  OK: 200,
  CREATED: 201,
  EMPTY: 204,
  NOT_MODIFIED: 304,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

export type HttpCodeValue = (typeof HttpCode)[keyof typeof HttpCode];
