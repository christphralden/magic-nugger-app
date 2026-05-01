Date: 02-05-2026 00:54:00
Author: christphralden
Title: 003-types

---

## Shared Types

Types live in `shared/src/types/{entity}.types.ts`. That folder is the source of truth — this doc only covers the conventions.

### Convention

Zod schema first, TypeScript type inferred from it — never write types by hand.

```ts
import { z } from "zod";

export const PlayerSchema = z.object({ ... });
export type Player = z.infer<typeof PlayerSchema>;
```

Schemas are exported alongside types so the server can reuse them in `validate.ts` middleware.

### Naming

| Shape              | Prefix/suffix     | Example                  |
| ------------------ | ----------------- | ------------------------ |
| DB / domain entity | none              | `Player`, `GameSession`  |
| API request body   | `Request` prefix  | `RequestCreateClassroom` |
| API response body  | `Response` prefix | `ResponseSession`        |

### API response wrapper

Every endpoint response is wrapped in `ApiResponse<T>`:

```ts
export const ApiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    code: z.number().int(),
    error: z.string(),
    data: dataSchema,
  });

export type ApiResponse<T> = {
  code: number;
  error: string;
  data: T;
};
```

### Example

```ts
// shared/src/types/player.types.ts
import { z } from "zod";

export const PlayerSchema = z.object({
  id: z.string().uuid(),
  username: z.string().max(32),
  display_name: z.string().max(64).nullable(),
  current_elo: z.number().int().min(0),
});
export type Player = z.infer<typeof PlayerSchema>;

export const RequestUpdatePlayerSchema = z.object({
  display_name: z.string().max(64).optional(),
  username: z.string().min(3).max(32).optional(),
  avatar_url: z.string().url().optional(),
});
export type RequestUpdatePlayer = z.infer<typeof RequestUpdatePlayerSchema>;

export const ResponsePlayerSchema = PlayerSchema.pick({
  id: true,
  username: true,
  display_name: true,
  current_elo: true,
});
export type ResponsePlayer = z.infer<typeof ResponsePlayerSchema>;
```

### File layout

```
shared/src/
├── types/
│   ├── api.types.ts        ApiResponse<T>
│   ├── player.types.ts     Player, ResponsePlayer, AppUser
│   ├── level.types.ts
│   ├── classroom.types.ts
│   ├── session.types.ts
│   └── elo.types.ts
└── index.ts                re-exports all types and schemas
```

### `index.ts`

```ts
export * from "./types/api.types";
export * from "./types/player.types";
export * from "./types/level.types";
export * from "./types/classroom.types";
export * from "./types/session.types";
export * from "./types/elo.types";
```
