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

## Entity Relationship Diagram

![ERD](docs/20250502_erd.png)

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
