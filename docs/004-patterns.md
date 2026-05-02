---
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

- `authenticate` and `authorize` are the **only** auth middleware. No wrapper middleware for ownership checks.
- Ownership checks (e.g. "is this user the teacher of this classroom?") live **inline in the handler**, not in middleware.
- Use `currentUser(req)` to access `req.user` safely — never use `req.user!`.

```ts
import { Router } from "express";
import { playerService } from "@/services/player.service";
import { validate } from "@/middleware/validate";
import { authenticate, currentUser } from "@/middleware/authenticate";
import { authorize } from "@/middleware/authorize";
import { toResponsePlayer } from "@/dto/player.dto";
import { AppError } from "@/errors/app-error";
import { RequestUpdatePlayerSchema, ErrorCode } from "@magic-nugger-app/shared";
import type { ApiResponse, ResponsePlayer } from "@magic-nugger-app/shared";

export const playersRouter = Router();

// Public
playersRouter.get("/:id", async (req, res) => {
  const player = await playerService.getById(req.params.id);
  res.json({
    code: 200,
    error: "",
    data: player,
  } satisfies ApiResponse<ResponsePlayer>);
});

// Authenticated
playersRouter.use(authenticate);

playersRouter.patch(
  "/:id",
  authorize("player:update"),
  validate(RequestUpdatePlayerSchema),
  async (req, res) => {
    const user = currentUser(req);
    if (user.id !== req.params.id) {
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

No try/catch in route handlers — Express 5 propagates async errors automatically.

Every `res.json` call uses `satisfies ApiResponse<T>` so TypeScript verifies the shape at compile time.

---

### Middleware

`web-server/src/middleware/`

Only two auth middleware exist: `authenticate` and `authorize`. No wrapper middleware (no `requireOwner`, `requireSelfOrPermission`, etc.).

`authenticate.ts`

```ts
import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error";
import { ErrorCode } from "@magic-nugger-app/shared";

export const authenticate = (
  req: Request,
  _res: Response,
  next: NextFunction,
) => {
  if (!req.isAuthenticated || !req.isAuthenticated()) {
    throw new AppError(ErrorCode.UNAUTHORIZED, "Unauthorized");
  }
  next();
};

export function currentUser(req: Request): Express.User {
  if (!req.user) {
    throw new AppError(ErrorCode.UNAUTHORIZED, "Unauthorized");
  }
  return req.user;
}
```

`authorize.ts`

```ts
import type { Request, Response, NextFunction } from "express";
import { AppError } from "@/errors/app-error";
import { ErrorCode } from "@magic-nugger-app/shared";

export const authorize =
  (...permissions: string[]) =>
  (req: Request, _res: Response, next: NextFunction) => {
    const user = req.user;
    if (!user) {
      throw new AppError(ErrorCode.UNAUTHORIZED, "Unauthorized");
    }
    const perms = user.role_permissions ?? [];
    if (perms.includes("*")) return next();
    const hasAll = permissions.every((p) => perms.includes(p));
    if (!hasAll) {
      throw new AppError(ErrorCode.FORBIDDEN, "Forbidden");
    }
    next();
  };
```

`validate.ts`

```ts
import type { ZodSchema } from "zod";
import type { Request, Response, NextFunction } from "express";
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

### `state/{name}.thunk.ts`

Thunks are just fetch calls — no business logic, no `getState`, no dispatching other actions.

```ts
import { createAsyncThunk } from "@reduxjs/toolkit";
import { WEB_SERVER_URL, API_VERSION_BASE } from "@/lib/api";
import type { RootState } from "@/store";
import type {
  ApiResponse,
  ResponsePlayer,
  RequestUpdatePlayer,
} from "@magic-nugger-app/shared";

export const fetchPlayer = createAsyncThunk<
  ResponsePlayer,
  string,
  { state: RootState }
>("player/fetchById", async (id, { rejectWithValue }) => {
  const response = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/players/${id}`,
    {
      credentials: "include",
      headers: { "Content-Type": "application/json" },
    },
  );
  const data = (await response.json()) as ApiResponse<ResponsePlayer>;
  if (!response.ok || data.code !== 200) {
    return rejectWithValue(data.error);
  }
  return data.data;
});

export const patchPlayer = createAsyncThunk<
  ResponsePlayer,
  { id: string; body: RequestUpdatePlayer },
  { state: RootState }
>("player/update", async ({ id, body }, { rejectWithValue }) => {
  const response = await fetch(
    `${WEB_SERVER_URL}/${API_VERSION_BASE}/players/${id}`,
    {
      method: "PATCH",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    },
  );
  const data = (await response.json()) as ApiResponse<ResponsePlayer>;
  if (!response.ok || data.code !== 200) {
    return rejectWithValue(data.error);
  }
  return data.data;
});
```

Rules:

- Only `fetch` and `rejectWithValue` — no side effects, no `dispatch`, no `getState`
- Check `response.ok` (and `data.code` when applicable)
- Owns exactly one `pending/fulfilled/rejected` lifecycle

---

### `state/{name}.slice.ts`

Slice, reducers, and selectors live together.

```ts
import { createSlice, createSelector } from "@reduxjs/toolkit";
import { weakMapMemoize } from "@reduxjs/toolkit";
import { fetchPlayer, patchPlayer } from "./player.thunk";
import type { RootState } from "@/store";
import type { ResponsePlayer } from "@magic-nugger-app/shared";

type PlayerState = {
  players: Record<string, ResponsePlayer>;
  loading: boolean;
  error: string | null;
};

const playerSlice = createSlice({
  name: "player",
  initialState: {
    players: {},
    loading: false,
    error: null,
  } as PlayerState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchPlayer.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchPlayer.fulfilled, (state, action) => {
        state.loading = false;
        state.players[action.payload.id] = action.payload;
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
        state.players[action.payload.id] = action.payload;
      })
      .addCase(patchPlayer.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
  selectors: {
    selectPlayerLoading: (state) => state.loading,
    selectPlayerError: (state) => state.error,
    selectPlayerById = createSelector(
      [
        (state: RootState) => state.player,
        (_state: RootState, id: string) => id,
      ],
      (playerState, id) => playerState.players[id] ?? null,
      { memoize: weakMapMemoize },
    ),
    selectPlayerCount = createSelector(
      [(state: RootState) => state.player],
      (playerState) => Object.keys(playerState.players).length,
    ),
    selectPlayerIds = createSelector(
      [(state: RootState) => state.player],
      (playerState) => Object.keys(playerState.players),
    ),
  },
});

export const { clearPlayers } = playerSlice.actions;
export const {
  selectPlayerLoading,
  selectPlayerError,
  selectPlayerById,
  selectPlayerCount,
  selectPlayerId,
} = playerSlice.selectors;
export const playerReducer = playerSlice.reducer;
```

Rules:

- Slice contains reducers and `extraReducers` only — thunks are imported from `.thunk.ts`
- `builder.addCase` (not map form) for full type inference on `action.payload`
- Simple selectors go in `createSlice.selectors`
- Memoized / parametric selectors use `createSelector` and live in the same file
- Parametric selectors use `weakMapMemoize` so every argument gets its own cache

---

### `actions/{name}.actions.ts`

Logic actions are manual thunks that orchestrate multiple operations: sequential dispatches, `getState` guards, cross-slice updates, and side effects. They do not import `store`.

```ts
import { isFulfilled } from "@reduxjs/toolkit";
import type { AppDispatch } from "@/store";
import type { RootState } from "@/store";
import { fetchPlayer, patchPlayer } from "@/feature/player/state/player.thunk";
import type { RequestUpdatePlayer } from "@magic-nugger-app/shared";

export const handlePlayerLoad =
  (playerId: string) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    // Guard: skip if already loaded
    const { player } = getState();
    if (player.players[playerId]) return;

    const result = await dispatch(fetchPlayer(playerId));

    if (isFulfilled(fetchPlayer)(result)) {
      console.log("Player loaded:", result.payload);
    } else {
      console.error("Failed to load player", result.payload);
    }
  };

export const handlePlayerUpdate =
  (playerId: string, body: RequestUpdatePlayer) =>
  async (dispatch: AppDispatch) => {
    const result = await dispatch(patchPlayer({ id: playerId, body }));

    if (isFulfilled(patchPlayer)(result)) {
      // dispatch();
    }
  };
```

Waterfall orchestration — dispatch thunks sequentially without breaking SRP:

```ts
import { createClassroom } from "@/feature/classroom/state/classroom.thunk";
import { sendInvite } from "@/feature/invite/state/invite.thunk";
import { classroomActions } from "@/feature/classroom/state/classroom.slice";
import { uiActions } from "@/feature/ui/state/ui.slice";
import type { CreateClassroomPayload } from "@magic-nugger-app/shared";

export const handleCreateClassroomAndInvite =
  (classroomData: CreateClassroomPayload, inviteeEmail: string) =>
  async (dispatch: AppDispatch, getState: () => RootState) => {
    // Step 1
    const classroomResult = await dispatch(createProject(classroomData));
    if (!isFulfilled(createClassroom)(classroomResult)) return;

    const classroomId = classroomResult.payload.id;

    // Step 2 — waterfall depends on step 1 result
    const inviteResult = await dispatch(
      sendInvite({ classroomId, email: inviteeEmail }),
    );
    if (!isFulfilled(sendInvite)(inviteResult)) {
      dispatch(classroomActions.markInviteFailed(projectId));
      return;
    }

    // Step 3 — cross-slice updates
    dispatch(uiActions.showToast("Classroom created and invite sent"));
    dispatch(classroomActions.setActiveClassroom(classroomId));
  };
```

Rules:

- Actions are manual thunks `(args) => async (dispatch, getState) => { ... }`
- Never import `store` — `dispatch` and `getState` are injected by the thunk middleware
- Never call `fetch` directly — dispatch thunks instead
- Branch on thunk results using `isFulfilled(thunk)(result)`
- Use `getState` for idempotent guards and conditional logic
- Can dispatch regular slice actions or thunks from any feature
- Each orchestrated thunk keeps its own lifecycle — no SRP violation

---

### `hooks/use-{name}.ts`

```ts
import { useAppDispatch, useAppSelector } from "@/store/hooks";
import { fetchPlayer } from "@/feature/player/state/player.thunk";
import { handlePlayerLoad } from "@/feature/player/actions/player.actions";
import {
  clearPlayers,
  selectPlayerById,
  selectPlayerLoading,
  selectPlayerError,
} from "@/feature/player/state/player.slice";
import type { RequestUpdatePlayer } from "@magic-nugger-app/shared";

export function usePlayer(id: string) {
  const dispatch = useAppDispatch();
  const player = useAppSelector((state) => selectPlayerById(state, id));
  const loading = useAppSelector(selectPlayerLoading);
  const error = useAppSelector(selectPlayerError);

  return {
    player,
    loading,
    error,
    load: () => dispatch(handlePlayerLoad(id)),
    directLoad: () => dispatch(fetchPlayer(id)),
    clear: () => dispatch(clearPlayers()),
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

Fetch thunk:

```
Component
  → use-{name} hook
    → dispatch(thunk)
      → state/{name}.thunk.ts
        → fetch /api/v1/...  (typed ApiResponse<T>)
            → validate → authenticate → authorize
            → route handler → service → db
          ← ApiResponse<T>
        ← res.data (typed)
      ← slice updated via extraReducers (state/{name}.slice.ts)
    ← selector (state/{name}.slice.ts)
  ← typed state
```

Logic action (orchestration / waterfall):

```
Component / Hook / Event Listener
  → dispatch(logicAction(args))
    → actions/{name}.actions.ts
      → getState() guard?
      → dispatch(fetchThunkA)
      → isFulfilled? → dispatch(fetchThunkB) → isFulfilled?
      → dispatch(crossSliceActions)
    ← thunks handle their own state slices
  ← no React re-render during orchestration
```

---

## DTOs

When we are transforming objects, we should have a dedicated plain transforming function that live in /dto/{entity}.dto.ts

Example: we would never want to expose the full attribute of a user, we transform to reduce sensitive fields to be consumed

`web-server/src/dto/player.dto.ts`

```ts
import type { AppUser, ResponsePlayer } from "@magic-nugger-app/shared";

export function toResponsePlayer(
  user: AppUser | null | undefined,
): ResponsePlayer | null {
  if (!user) return null;
  return {
    id: user.id,
    username: user.username,
    display_name: user.display_name,
    current_elo: user.current_elo,
    highest_level_unlocked: user.highest_level_unlocked,
    avatar_url: user.avatar_url,
  };
}
```

---

## Type Augmentation

`web-server/src/types/express.d.ts`

```ts
import type { AppUser } from "@magic-nugger-app/shared";

declare global {
  namespace Express {
    interface User extends AppUser {}
  }
}
```

This lets `req.user` be typed as `AppUser` across the entire backend without casting.

---

## Invariants

| Rule                                                       | Layer       |
| ---------------------------------------------------------- | ----------- |
| Services never import Express                              | services/   |
| Only `AppError` thrown from services                       | services/   |
| Only `authenticate` and `authorize` middleware exist       | middleware/ |
| Never use `req.user!` — use `currentUser(req)`             | routes/     |
| Never return `AppUser` in API responses — use DTOs         | routes/     |
| Ownership checks live inline in handlers, not middleware   | routes/     |
| Thunks are just fetch calls — no business logic            | state/      |
| Selectors live in the slice file                           | state/      |
| Every `res.json` uses `satisfies ApiResponse<T>`           | routes/     |
| Components never call `fetch`, `dispatch`, or import store | components/ |
| Actions are manual thunks — no store import                | actions/    |
| All filenames are kebab-case                               | everywhere  |
