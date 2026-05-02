---
Date: 02-05-2026 00:20:00
Author: christphralden
Title: 002-monorepo
---

## Monorepo Structure

```
magic-nugger-app/
├── db/
│   ├── migrations/
│   │   ├── apply/        atomic schema patches (DO block with _v.try_register_patch)
│   │   └── rollback/     corresponding rollback scripts
│   └── runner.mjs        custom patch runner (up / down)
├── nginx/
│   └── frontend.nginx.conf  production reverse proxy + CSP
├── web-server/
│   └── src/
│       ├── routes/       auth, players, levels, sessions, leaderboard, classrooms, admin
│       ├── middleware/   authenticate.ts, authorize.ts, validate.ts, error-handler.ts
│       ├── services/     elo.service.ts, session.service.ts, leaderboard.service.ts, classroom.service.ts, player.service.ts
│       ├── dto/          player.dto.ts (response DTOs — strip sensitive fields)
│       ├── errors/       app-error.ts
│       ├── db/           client.ts
│       ├── config/       passport.ts
│       ├── types/        express.d.ts (Express.User augmentation)
│       └── cache/        leaderboard.cache.ts
├── web-app/
│   └── src/
│       ├── pages/        login, level-select, game, profile, leaderboard, classroom
│       ├── feature/
│       │   └── {name}/
│       │       ├── components/
│       │       ├── hooks/
│       │       ├── state/        {name}.slice.ts, {name}.thunk.ts
│       │       └── actions/      {name}.actions.ts
│       ├── store/        index.ts, hooks.ts
│       ├── lib/          api.ts
│       └── hooks/        use-unity-bridge.ts
├── shared/
│   └── src/
│       ├── types/        {entity}.types.ts (Zod schemas + inferred types)
│       ├── utils/        try-catch.ts
│       ├── constants/    error-codes.ts
│       └── index.ts
├── docs/
├── .github/workflows/    pr-check.yml, deploy.yml
├── docker-compose.yml + docker-compose.dev.yml
├── .env.example
└── package.json          workspace root
```

All filenames are kebab-case across the entire codebase.

Unity project lives in a separate repo https://github.com/KRook0110/MagicNagger. Unity CI builds the WebGL artifact and uploads it; web CI downloads and bundles it into `web-app/public/unity/` (gitignored).

### Shared types — npm workspaces

Root `package.json`:

```json
{
  "name": "magic-nugger-app",
  "private": true,
  "workspaces": ["web-server", "web-app", "shared"]
}
```

`shared/package.json`:

```json
{
  "name": "@magic-nugger-app/shared",
  "version": "1.0.0",
  "types": "./src/index.ts"
}
```

`types` points directly to raw TS source — no build step needed on `shared`. Vite and ts-node both handle TS natively and follow the symlink.

Both `web-server/package.json` and `web-app/package.json`:

```json
{
  "dependencies": {
    "@magic-nugger-app/shared": "*"
  }
}
```

`npm install` from the workspace root creates a symlink `node_modules/@magic-nugger-app/shared → ../../shared`. Import in either project:

```ts
import type { Player, GameSession } from "@magic-nugger-app/shared";
```

Add to both `web-server/tsconfig.json` and `web-app/tsconfig.json` so `tsc --noEmit` resolves the path:

```json
{
  "compilerOptions": {
    "paths": {
      "@magic-nugger-app/shared": ["../shared/src"]
    }
  }
}
```
