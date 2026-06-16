# Magic Nugger App

## Educational tower defense game for ages 6–12. Solve math equations to defend against enemies.

## Game Repo: [Calculon](https://github.com/KRook0110/MagicNagger)

## Release Notes

On new [Unity Build](https://github.com/KRook0110/MagicNagger) update release

```bash
git tag -d <tag>
git push push origin --delete <tag>
gh release create <tag> <src> --title "<title>" --notes "<notes>"
```

## Quick Start

### Option A: Docker for DB, local server + web app (recommended)

Run Postgres in Docker, run the server and web app locally for hot reload.

```bash
# 1. Environment
cp .env.local.example .env.local
# Fill in: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, SESSION_SECRET, APP_USER_PASSWORD, POSTGRES_PASSWORD

# 2. Install dependencies
npm install

# 3. Start Postgres + cron
docker compose --env-file=.env.local -f docker-compose.dev.yml up -d magic-nugger-postgres magic-nugger-cron

# 4. Run migrations
npm run db:migrate

# 5. Start web server (terminal 1)
cd web-server && npm run dev

# 6. Start web app (terminal 2)
cd web-app && npm run dev
```

- web-app on `http://localhost:5173`
- web-server on `http://localhost:3000`
- db on `localhost:5432`

To stop:

```bash
docker compose --env-file=.env.local -f docker-compose.dev.yml down
```

---

### Option B: No Docker (everything local)

Requires a local PostgreSQL 16 instance.

```bash
# 1. Environment
cp .env.local.example .env.local
# Set POSTGRES_HOST=localhost and fill in credentials

# 2. Install & migrate
npm install
npm run db:migrate

# 3. Start services
cd web-server && npm run dev
cd web-app && npm run dev
```

---

## Entity Relationship Diagram (2026-05-06)

```mermaid
erDiagram
    permissions {
        serial      id   PK
        varchar     name UK
    }

    roles {
        serial  id          PK
        varchar name        UK
        text    description
    }

    role_permissions {
        int role_id       FK
        int permission_id FK
    }

    players {
        uuid        id                       PK
        varchar     username                 UK
        varchar     display_name
        varchar     email                    UK
        text        avatar_url
        int         role_id                  FK
        varchar     oauth_provider
        varchar     oauth_id
        text        password_hash
        int         current_elo
        int         highest_level_unlocked
        int         total_questions_answered
        int         total_correct
        int         total_incorrect
        int         longest_streak
        timestamptz created_at
        timestamptz updated_at
        timestamptz last_active_at
    }

    levels {
        serial      id                  PK
        varchar     name
        text        description
        int         order_index         UK
        int         elo_min
        int         elo_gain_correct
        int         elo_loss_incorrect
        int         time_limit_seconds
        jsonb       enemy_wave_config
        jsonb       question_gen_config
        int         max_score
        boolean     is_active
        timestamptz created_at
        timestamptz updated_at
    }

    classrooms {
        uuid        id           PK
        varchar     name
        text        description
        uuid        teacher_id   FK
        varchar     visibility
        int         starting_elo
        int         elo_cap
        varchar     invite_code  UK
        boolean     is_active
        timestamptz created_at
        timestamptz updated_at
    }

    classroom_members {
        uuid        classroom_id FK
        uuid        player_id    FK
        int         classroom_elo
        timestamptz joined_at
    }

    game_sessions {
        uuid        id              PK
        uuid        player_id       FK
        int         level_id        FK
        varchar     status
        int         score
        int         max_answers
        int         elo_before
        int         elo_after
        int         elo_delta
        int         correct_count
        int         incorrect_count
        int         max_streak
        int         current_streak
        timestamptz started_at
        timestamptz ended_at
        inet        client_ip
        text        user_agent
    }

    session_answers {
        bigint      id            PK
        uuid        session_id    FK
        boolean     is_correct
        int         elo_delta
        int         time_taken_ms
        timestamptz answered_at
    }

    elo_history {
        bigint      id         PK
        uuid        player_id  FK
        uuid        session_id FK
        int         elo_before
        int         elo_after
        int         delta
        varchar     reason
        timestamptz created_at
    }

    session {
        varchar     sid    PK
        json        sess
        timestamp   expire
    }

    audit.audit_events {
        uuid        id          PK
        uuid        user_id     FK
        varchar     url
        smallint    status_code
        inet        ip_address
        text        user_agent
        jsonb       metadata
        timestamptz created_at
        varchar     http_method
    }

    audit.log_events {
        uuid        id         PK
        uuid        user_id    FK
        varchar     event
        varchar     level
        jsonb       metadata
        text        description
        timestamptz created_at
    }

    roles            ||--|{ role_permissions    : "role_id"
    permissions      ||--|{ role_permissions    : "permission_id"
    roles            ||--o{ players             : "role_id"
    players          ||--o{ classrooms          : "teacher_id"
    players          ||--o{ classroom_members   : "player_id"
    classrooms       ||--o{ classroom_members   : "classroom_id"
    players          ||--o{ game_sessions       : "player_id"
    levels           ||--o{ game_sessions       : "level_id"
    game_sessions    ||--o{ session_answers     : "session_id"
    players          ||--o{ elo_history         : "player_id"
    game_sessions    |o--o{ elo_history         : "session_id"
    players          |o--o{ audit.audit_events  : "user_id"
    players          |o--o{ audit.log_events    : "user_id"

```

- `session` managed sessions added 2026-05-06.
- `audit_events` (weekly partitioned, `audit` schema) added 2026-05-06.
- `log_events` (weekly partitioned, `audit` schema) added 2026-05-07. Used by cron jobs and future structured logging.

---

## Project Structure

```

magic-nugger-app/
├── db/
├── docs/
├── nginx/
├── shared/
├── web-app/
├── web-server/
└── .github/workflows/

```

---

## Database Utilities

```bash
# Apply all pending migrations
npm run db:migrate

# Rollback the most recent migration
npm run db:rollback

# Manual backup → db/backups/backup_YYYYMMDD_HHMMSS.sql (requires dev postgres running)
npm run db:backup

# Restore from a dump file
npm run db:restore -- db/backups/backup_20260507_020000.sql
```

Automated weekly backups run via the `magic-nugger-cron` container (Sundays at 02:00). See [`docs/007-cron-jobs.md`](docs/007-cron-jobs.md) for cron job details.

---

## Running Tests

```bash
# Backend tests
npm run test --workspace=web-server

# Frontend tests
npm run test --workspace=web-app

# All tests
npm test
```

---

## Environment Variables

Copy `.env.local.example` to `.env.local` for local dev. See `.env.production.example` for the production shape (written by CI).

Refer to: [DEPLOYMENT.md](https://github.com/christphralden/magic-nugger-app/blob/master/DEPLOYMENT.md)

---

## Tech Stack

| Layer    | Tech                                                    |
| -------- | ------------------------------------------------------- |
| Frontend | React 18, Vite, Redux Toolkit, Tailwind CSS, shadcn/ui  |
| Backend  | Express 5,                                              |
| Database | PostgreSQL 16                                           |
| Shared   | @magic-nugger-app lib                                   |
| Auth     | Cookie sessions (no JWT), Google OAuth + local password |
| Tests    | Jest (backend + frontend), jsdom                        |
| Deploy   | Docker Compose on EC2, Nginx reverse proxy              |

---

## License

Skripsi — Jonathan, Alden, Shawn
