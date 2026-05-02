# Magic Nugger App

Educational tower defense game for ages 6–12. Solve math equations to defend against enemies.

**Monorepo:** `web-app` (React + Vite) · `web-server` (Express 5 + PostgreSQL) · `shared` (Zod schemas + types)

---

## Prerequisites

- [Node.js](https://nodejs.org/) 20+
- [npm](https://www.npmjs.com/) 10+
- [Docker](https://www.docker.com/) + [Docker Compose](https://docs.docker.com/compose/)
- PostgreSQL 16 (if not using Docker for DB)

---

## Quick Start

### Option A: Full Docker Compose (quickest)

Everything runs in containers — best for a first-time run or CI.

```bash
# 1. Environment
cp .env.example .env
# Edit .env and fill in GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, SESSION_SECRET

# 2. Install workspace dependencies
npm install

# 3. Start everything
npm run db:migrate
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

```

- web-app on `http://localhost:5173`
- web-server on `http://localhost:3000`

To stop:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml down
```

---

### Option B: Docker for DB only (recommended for development)

Run Postgres in Docker, run the web app and server locally for hot reload.

```bash
# 1. Start only Postgres
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d postgres

# 2. Install dependencies
npm install

# 3. Run migrations
npm run db:migrate

# 4. Start web server (terminal 1)
cd web-server && npm run dev

# 5. Start web app (terminal 2)
cd web-app && npm run dev
```

- web-app on `http://localhost:5173`
- web-server on `http://localhost:3000`
- db on `localhost:5432`

---

### Option C: No Docker (everything local)

You need a local PostgreSQL 16 instance.

```bash
# 1. Create the database
createdb magic_nugger

# 2. Environment
cp .env.example .env
# Set DATABASE_URL=postgresql://user:pass@localhost:5432/magic_nugger

# 3. Install & migrate
npm install
npm run db:migrate

# 4. Start services
cd web-server && npm run dev
cd web-app && npm run dev
```

---

## Entity Relationship Diagram (2025-05-02)

````mermaid
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

    roles            ||--|{ role_permissions  : "role_id"
    permissions      ||--|{ role_permissions  : "permission_id"
    roles            ||--o{ players           : "role_id"
    players          ||--o{ classrooms        : "teacher_id"
    players          ||--o{ classroom_members : "player_id"
    classrooms       ||--o{ classroom_members : "classroom_id"
    players          ||--o{ game_sessions     : "player_id"
    levels           ||--o{ game_sessions     : "level_id"
    game_sessions    ||--o{ session_answers   : "session_id"
    players          ||--o{ elo_history       : "player_id"
    game_sessions    |o--o{ elo_history       : "session_id"
```---

## Project Structure

````

magic-nugger-app/
├── db/
├── docs/
├── nginx/
├── shared/
├── web-app/
├── web-server/
└── .github/workflows/

````

---

## Running Tests

```bash
# Backend tests
npm run test --workspace=web-server

# Frontend tests
npm run test --workspace=web-app

# All tests
npm test
````

---

## Environment Variables

Copy `.env.example` to `.env` and fill in:

| Variable               | Required | Description                                        |
| ---------------------- | -------- | -------------------------------------------------- |
| `DATABASE_URL`         | Yes      | Postgres connection string                         |
| `SESSION_SECRET`       | Yes      | Cookie session secret                              |
| `GOOGLE_CLIENT_ID`     | Yes\*    | Google OAuth client ID                             |
| `GOOGLE_CLIENT_SECRET` | Yes\*    | Google OAuth client secret                         |
| `CORS_ORIGIN`          | No       | Frontend origin (default: `http://localhost:5173`) |
| `PORT`                 | No       | Server port (default: `3000`)                      |

\*Required only if using Google OAuth. Local password auth works without it.

---

## Tech Stack

| Layer    | Tech                                                    |
| -------- | ------------------------------------------------------- |
| Frontend | React 18, Vite, Redux Toolkit, Tailwind CSS, shadcn/ui  |
| Backend  | Express 5,                                              |
| Database | PostgreSQL 16                                           |
| Shared   | Application global types, shared utils                  |
| Auth     | Cookie sessions (no JWT), Google OAuth + local password |
| Tests    | Jest (backend + frontend), jsdom                        |
| Deploy   | Docker Compose on EC2, Nginx reverse proxy              |

---

## License

Skripsi — Jonathan, Alden, Shawn
