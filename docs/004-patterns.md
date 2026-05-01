Date: 02-05-2026
Author: christphralden
Title: 004-patterns

---

## Patterns

### Naming

All filenames are kebab-case. No exceptions.

---

## Backend

### `AppError`

`web-server/src/errors/app-error.ts`

```ts
export class AppError extends Error {
  statusCode: number;

  constructor(statusCode: number, message: string) {
    super(message);
    this.statusCode = statusCode;
    this.name = "AppError";
    Object.setPrototypeOf(this, new.target.prototype);
  }
}
```

`Object.setPrototypeOf` is required so `instanceof AppError` works correctly when targeting ES5.

---

### DB

IMPORTANT: db should always use a prepared statement. use a db framework correctly, adjust example code accordingly

### Service

`web-server/src/services/{entity}.service.ts`

```ts
import { db } from "@db/client";
import { AppError } from "@/errors/app-error";
import { ErrorCode } from "@magic-nugger-app/shared";
import type {
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export const playerService = {
  async getById(id: string): Promise<ResponsePlayer> {
    const { rows } = await db.query<ResponsePlayer>(
      `SELECT id, username, display_name, current_elo FROM players WHERE id = $1`,
      [id],
    );
    if (!rows[0]) throw new AppError(ErrorCode.NOT_FOUND, "Player not found");
    return rows[0];
  },
};
```

Rules:

- Plain `const` object — not a class
- Async methods typed with shared Request/Response types
- Only throws `AppError` — catches raw pg errors at the service boundary and wraps them
- Never imports from Express (`req`, `res`, `next`)

---

### Route handler

`web-server/src/routes/{entity}.ts`

Pipeline: `validate → authenticate → authorize → handler`
authenticate and authorize should live in middleware layer

```ts
import { Router } from "express";
import { playerService } from "@/services/player.service";
import { validate } from "@/middleware/validate";
import { AppError } from "@/errors/app-error";
import { RequestUpdatePlayerSchema, ErrorCode } from "@magic-nugger-app/shared";
import type { ApiResponse, ResponsePlayer } from "@magic-nugger-app/shared";

export const playersRouter = Router();

playersRouter.get("/:id", async (req, res) => {
  const player = await playerService.getById(req.params.id);
  res.json({
    code: 200,
    error: "",
    data: player,
  } satisfies ApiResponse<ResponsePlayer>);
});

playersRouter.patch(
  "/:id",
  validate(RequestUpdatePlayerSchema),
  async (req, res) => {
    if (
      req.session.playerId !== req.params.id &&
      req.session.role !== "admin"
    ) {
      throw new AppError(ErrorCode.FORBIDDEN, "Forbidden");
    }
    const player = await playerService.update(req.params.id, req.body);
    res.json({
      code: 200,
      error: "",
      data: player,
    } satisfies ApiResponse<ResponsePlayer>);
  },
);
```

No try/catch in route handlers — Express 5 propagates async errors automatically. On Express 4, wrap with an `async-handler` utility.

Every `res.json` call uses `satisfies ApiResponse<T>` so TypeScript verifies the shape at compile time. But code should explicitly show that it is ApiResponse always type explicitly

---

### middleware

authentication, authorization, request validation should be handled here

`web-server/src/middleware/validate.ts`

```ts
import { ZodSchema } from "zod";
import { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error";
import { ErrorCode } from "@magic-nugger-app/shared";

export const validate =
  <T>(schema: ZodSchema<T>) =>
  (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      throw new AppError(ErrorCode.BAD_REQUEST, result.error.issues[0].message);
    }
    req.body = result.data;
    next();
  };
```

---

### Global error handler

`web-server/src/middleware/error-handler.ts` — registered last in `app.ts`

```ts
import { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error";
import type { ApiResponse } from "@magic-nugger-app/shared";

export const errorHandler = (
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      code: err.statusCode,
      error: err.message,
      data: null,
    } satisfies ApiResponse<null>);
  }

  console.error(err);
  res.status(500).json({
    code: 500,
    error: "Internal server error",
    data: null,
  } satisfies ApiResponse<null>);
};
```

---

## Shared

### `tryCatch`

`shared/src/utils/try-catch.ts`

```ts
export async function tryCatch<T>(
  promise: Promise<T>,
): Promise<[null, T] | [Error, null]> {
  try {
    return [null, await promise];
  } catch (err) {
    return [err instanceof Error ? err : new Error(String(err)), null];
  }
}
```

Go-style error-as-value. Use it for flat branching without nested catch blocks.

```ts
const [err, player] = await tryCatch(playerService.getById(id));
if (err) return rejectWithValue(err.message);
```

---

### `ErrorCode`

`shared/src/constants/error-codes.ts`

```ts
export const ErrorCode = {
  OK: 200,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL: 500,
} as const;

export type ErrorCodeValue = (typeof ErrorCode)[keyof typeof ErrorCode];
```

Each value is a literal type (`ErrorCode.NOT_FOUND` → `404`, not `number`). Used in both `AppError` throws and frontend response checks.

---

## Frontend

`web-app/src/lib/api.ts`

```ts
export const WEB_SERVER_URL = import.meta.env.VITE_WEB_SERVER_URL ?? "...url";
export const API_VERSION_BASE = import.meta.env.VITE_API_URL ?? "api/v1";
```

No apiClient wrapper. Thunks call `fetch` directly. Every fetch sets `credentials: "include"` and `Content-Type: application/json` inline.

---

### Redux store

`web-app/src/store/index.ts`

```ts
import { configureStore } from "@reduxjs/toolkit";
import { playerReducer } from "@/feature/player/state/player.slice";

export const store = configureStore({
  reducer: {
    player: playerReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

`web-app/src/store/hooks.ts`

```ts
import { useDispatch, useSelector } from "react-redux";
import type { RootState, AppDispatch } from "./index";

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector = useSelector.withTypes<RootState>();
```

Components import from `store/hooks.ts` only — never from `store/index.ts`.

---

### Feature pattern

One example shows the full chain. All features follow the same structure.

### `actions/{name}.actions.ts`

```ts
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type {
  ApiResponse,
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export async function fetchPlayerById(id: string): Promise<ResponsePlayer> {
  const res: ApiResponse<ResponsePlayer> = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/players/${id}`,
    {
      credentials: "include",
    },
  ).then((r) => r.json());

  if (res.code !== 200) throw new Error(res.error);
  return res.data;
}

export async function updatePlayer(
  id: string,
  body: RequestUpdatePlayer,
): Promise<ResponsePlayer> {
  const res: ApiResponse<ResponsePlayer> = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/players/${id}`,
    {
      method: "PATCH",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    },
  ).then((r) => r.json());

  if (res.code !== 200) throw new Error(res.error);
  return res.data;
}
```

Rules:

- No Redux imports
- Typed with `ApiResponse<T>` at the fetch call site
- Checks `res.code`, throws on non-200
- Returns `res.data` (fully typed)

---

### `state/{name}.slice.ts`

```ts
import {
  createSlice,
  createAsyncThunk,
  createSelector,
} from "@reduxjs/toolkit";
import { tryCatch } from "@magic-nugger-app/shared";
import {
  fetchPlayerById,
  updatePlayer,
} from "@/feature/player/actions/player.actions";
import type { RootState } from "@/store";
import type {
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export const fetchPlayer = createAsyncThunk(
  "player/fetchById",
  async (id: string, { rejectWithValue }) => {
    const [err, player] = await tryCatch(fetchPlayerById(id));
    if (err) return rejectWithValue(err.message);
    return player;
  },
);

export const patchPlayer = createAsyncThunk(
  "player/update",
  async (
    { id, body }: { id: string; body: RequestUpdatePlayer },
    { rejectWithValue },
  ) => {
    const [err, player] = await tryCatch(updatePlayer(id, body));
    if (err) return rejectWithValue(err.message);
    return player;
  },
);

type PlayerState = {
  current: ResponsePlayer | null;
  loading: boolean;
  error: string | null;
};

const playerSlice = createSlice({
  name: "player",
  initialState: { current: null, loading: false, error: null } as PlayerState,
  reducers: {
    clearPlayer: (state) => {
      state.current = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchPlayer.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchPlayer.fulfilled, (state, action) => {
        state.loading = false;
        state.current = action.payload;
      })
      .addCase(fetchPlayer.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      .addCase(patchPlayer.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(patchPlayer.fulfilled, (state, action) => {
        state.loading = false;
        state.current = action.payload;
      })
      .addCase(patchPlayer.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { clearPlayer } = playerSlice.actions;
export const playerReducer = playerSlice.reducer;

const selectPlayerState = (state: RootState) => state.player;
export const selectCurrentPlayer = createSelector(
  selectPlayerState,
  (s) => s.current,
);
export const selectPlayerLoading = createSelector(
  selectPlayerState,
  (s) => s.loading,
);
export const selectPlayerError = createSelector(
  selectPlayerState,
  (s) => s.error,
);
```

Rules:

- `tryCatch` always wraps the action call — no raw try/catch in thunks
- `builder.addCase` (not map form) for full type inference on `action.payload`
- `createSelector` for every selector, even simple ones

---

### `hooks/use-{name}.ts`

```ts
import { useAppDispatch, useAppSelector } from "@/store/hooks";
import {
  fetchPlayer,
  patchPlayer,
  clearPlayer,
  selectCurrentPlayer,
  selectPlayerLoading,
  selectPlayerError,
} from "@/feature/player/state/player.slice";
import type { RequestUpdatePlayer } from "@magic-nugger-app/shared";

export function usePlayer(id: string) {
  const dispatch = useAppDispatch();
  const player = useAppSelector(selectCurrentPlayer);
  const loading = useAppSelector(selectPlayerLoading);
  const error = useAppSelector(selectPlayerError);

  return {
    player,
    loading,
    error,
    load: () => dispatch(fetchPlayer(id)),
    update: (body: RequestUpdatePlayer) => dispatch(patchPlayer({ id, body })),
    clear: () => dispatch(clearPlayer()),
  };
}
```

Thin adapter only — no logic, no fetch, no direct Redux imports beyond hooks.

---

### `components/`

```tsx
export function PlayerProfile({ playerId }: { playerId: string }) {
  const { player, loading, error, load } = usePlayer(playerId);

  useEffect(() => {
    load();
  }, [playerId]);

  if (loading) return <p>Loading…</p>;
  if (error) return <p>{error}</p>;
  if (!player) return null;

  return (
    <div>
      <h1>{player.display_name ?? player.username}</h1>
    </div>
  );
}
```

Rules:

- Calls feature hooks only — never `fetch`, `dispatch`, or `store` directly
- No business logic in JSX
- Composition over prop drilling

---

## Data flow

```
Component
  → use-{name} hook
    → dispatch(thunk)
      → {name}.actions.ts
        → fetch /api/v1/...  (typed ApiResponse<T>)
            → validate → authenticate → authorize
            → route handler → service → db
          ← ApiResponse<T>
        ← res.data (typed)
      ← slice updated via extraReducers
    ← selector
  ← typed state
```

---

## Invariants

| Rule                                                       | Layer       |
| ---------------------------------------------------------- | ----------- |
| Services never import Express                              | services/   |
| Only `AppError` thrown from services                       | services/   |
| No raw try/catch in thunks — use `tryCatch`                | state/      |
| Every `res.json` uses `satisfies ApiResponse<T>`           | routes/     |
| Components never call `fetch`, `dispatch`, or import store | components/ |
| Thunks live in state/, fetch calls live in actions/        | feature/    |
| All filenames are kebab-case                               | everywhere  |
