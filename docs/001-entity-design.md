Date: 01-05-2026 23:20:00
Author: christphralden
Title: 001-entity-design

---

# Magic Nugger Entity Relationship Design

Affected Services:

- web-app
- web-sever

---

# Preface

This is an education tower defence game. Age 6-12
Online game in a web using unity

Enemies are moving towards you, you need to solve math equations to defend against them
There will be n levels where each level the question gets gradually harder
Each player will have an elo associated with them
Each question will have a corresponding point that will contribute to your elo

# Database

- Relational
- Just use postgres probably
- No premature caching bcs we probably dont need that shit
- What about frequent writes? we are not going to scale so i think node can easily handle 100rps
- WAL? pretty overkill, lets get the base done and implement that later if needed.

# Web App

- React
- Thats it

# Web Server

- Just use node and express
- Typescript
- HTTP and probably use websocket to support any shit that comes

### Use case

> Why even having a webserver?

handling authentication, authorization, user sessions and scoreboard

### Authentication

who doesnt have google right now? just use OAuth
or simple password sign-in

jwt? do we really wanna handle refresh tokens and shit? no. just use session i dont care

### Authorization

ur typical RBAC
roles: student, teacher / parent (i have no idea), admin

### User Sessions

> Concept

We have concepts of:

- Level: each stage is a level. it determines how hard the level and what questions are generated
- Elo: a point system that determines your level

Each player has an elo
Each level has a minimum elo

Punish wrong answers, while add correct answers

> What to track?

- How many question was answered correctly
- How many question was answered incorrectly
- How long is a streak of correct questions
- What else hmm?

### Leaderboard

We have a global and a level leaderboard

global: maxx elo
level: maxx points

---

# Finalized Architecture Design

## Database Schema

### `roles`

```sql
CREATE TABLE roles (
  id          SERIAL      PRIMARY KEY,
  name        VARCHAR(32) NOT NULL UNIQUE,
  description TEXT
);

-- Seed
INSERT INTO roles (name) VALUES ('student'), ('teacher'), ('admin');
```

One role per player. A player cannot hold multiple roles.

---

### `players`

```sql
CREATE TABLE players (
  id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  username                 VARCHAR(32) NOT NULL UNIQUE,
  display_name             VARCHAR(64),
  email                    VARCHAR(255) NOT NULL UNIQUE,
  avatar_url               TEXT,
  role_id                  INTEGER     NOT NULL DEFAULT 1 REFERENCES roles(id),
  oauth_provider           VARCHAR(32),
  oauth_id                 VARCHAR(255),
  password_hash            TEXT,
  current_elo              INTEGER     NOT NULL DEFAULT 1000,
  highest_level_unlocked   INTEGER     NOT NULL DEFAULT 1,
  total_questions_answered INTEGER     NOT NULL DEFAULT 0,
  total_correct            INTEGER     NOT NULL DEFAULT 0,
  total_incorrect          INTEGER     NOT NULL DEFAULT 0,
  longest_streak           INTEGER     NOT NULL DEFAULT 0,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_active_at           TIMESTAMPTZ,
  CONSTRAINT oauth_or_password CHECK (
    (oauth_provider IS NOT NULL AND oauth_id IS NOT NULL) OR
    (password_hash IS NOT NULL)
  )
);

CREATE INDEX idx_players_elo   ON players (current_elo DESC);
CREATE INDEX idx_players_email ON players (email);
CREATE INDEX idx_players_oauth ON players (oauth_provider, oauth_id)
  WHERE oauth_provider IS NOT NULL;
```

Design decisions:

- UUID over BIGSERIAL: IDs appear in API responses and URLs, no enumeration risk
- `current_elo` is the uncapped global ELO, denormalized for leaderboard read performance
- Aggregate snapshot columns (`total_correct` etc.) updated atomically at session-end to avoid re-aggregating session_answers on every profile view
- ELO floor = 0 enforced in `elo.service.ts`, not at the DB level

---

### `levels`

```sql
CREATE TABLE levels (
  id                  SERIAL      PRIMARY KEY,
  name                VARCHAR(64) NOT NULL,
  description         TEXT,
  order_index         INTEGER     NOT NULL UNIQUE,
  elo_min    INTEGER     NOT NULL DEFAULT 0,
  elo_gain_correct    INTEGER     NOT NULL DEFAULT 15,
  elo_loss_incorrect  INTEGER     NOT NULL DEFAULT 5,
  time_limit_seconds  INTEGER,
  enemy_wave_config   JSONB       NOT NULL DEFAULT '{}',
  question_gen_config JSONB       NOT NULL DEFAULT '{}',
  max_score           INTEGER     NOT NULL DEFAULT 1000,
  is_active           BOOLEAN     NOT NULL DEFAULT true,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

`enemy_wave_config` and `question_gen_config` are opaque JSONB blobs passed verbatim to Unity. Server only reads `question_gen_config.count` for anti-abuse enforcement.

`question_gen_config` example:

```json
{
    "schema": 1
    "data":{
        "operations": ["addition", "subtraction"],
        "range_min": 0,
        "range_max": 20,
        "count": 10
    }

}
```

`elo_gain_correct > elo_loss_incorrect` by design — ensures net positive ELO for players answering correctly more than ~25% of the time. Higher levels have larger gain AND loss for more volatility.

---

### `classrooms`

```sql
CREATE TABLE classrooms (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR(128) NOT NULL,
  description TEXT,
  teacher_id  UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  visibility  VARCHAR(16) NOT NULL DEFAULT 'private'
              CHECK (visibility IN ('private', 'public')),
  elo_cap     INTEGER,
  invite_code VARCHAR(16) NOT NULL UNIQUE,
  is_active   BOOLEAN     NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_classrooms_teacher ON classrooms (teacher_id);
CREATE INDEX idx_classrooms_invite  ON classrooms (invite_code);
```

`elo_cap`: when set, `classroom_members.classroom_elo` is capped at this value at session-end. `NULL` = no cap. Teachers use this to control how fast students progress.

`visibility`:

- `private` — only teacher and enrolled students see the classroom leaderboard
- `public` — classroom leaderboard visible to all authenticated users

---

### `classroom_members`

```sql
CREATE TABLE classroom_members (
  classroom_id  UUID    NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
  player_id     UUID    NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  classroom_elo INTEGER NOT NULL DEFAULT 1000,
  joined_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (classroom_id, player_id)
);

CREATE INDEX idx_members_player ON classroom_members (player_id);
```

Two ELO tracks exist:

- `players.current_elo` — global, uncapped. Used for global leaderboard and level unlock gating.
- `classroom_members.classroom_elo` — per-classroom, capped at `classrooms.elo_cap`. Used for classroom leaderboard only.

A student can be a member of multiple classrooms. `classroom_elo` starts at the player's current ELO at time of joining.

---

### `game_sessions`

```sql
CREATE TABLE game_sessions (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  level_id        INTEGER     NOT NULL REFERENCES levels(id),
  status          VARCHAR(16) NOT NULL DEFAULT 'in_progress'
                  CHECK (status IN ('in_progress', 'completed', 'failed', 'abandoned')),
  score           INTEGER     NOT NULL DEFAULT 0,
  max_answers     INTEGER     NOT NULL DEFAULT 0,
  elo_before      INTEGER     NOT NULL,
  elo_after       INTEGER,
  elo_delta       INTEGER,
  correct_count   INTEGER     NOT NULL DEFAULT 0,
  incorrect_count INTEGER     NOT NULL DEFAULT 0,
  max_streak      INTEGER     NOT NULL DEFAULT 0,
  current_streak  INTEGER     NOT NULL DEFAULT 0,
  started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at        TIMESTAMPTZ,
  client_ip       INET,
  user_agent      TEXT
);

CREATE INDEX idx_sessions_player ON game_sessions (player_id, started_at DESC);
CREATE INDEX idx_sessions_level  ON game_sessions (level_id, score DESC)
  WHERE status = 'completed';
```

`max_answers` is populated at session creation from `level.question_gen_config.count`. Server rejects answer events once `correct_count + incorrect_count >= max_answers`.

---

### `session_answers`

```sql
CREATE TABLE session_answers (
  id            BIGSERIAL   PRIMARY KEY,
  session_id    UUID        NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
  is_correct    BOOLEAN     NOT NULL,
  elo_delta     INTEGER     NOT NULL,
  time_taken_ms INTEGER,
  answered_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_answers_session ON session_answers (session_id, answered_at);
```

No `question_id` — Unity owns question generation. Server only receives `{ is_correct, time_taken_ms }` per answer. `BIGSERIAL` PK used for B-tree-friendly sequential inserts on this high-volume table.

Written immediately on each answer event (no data loss if browser crashes mid-session).

---

### `elo_history`

```sql
CREATE TABLE elo_history (
  id          BIGSERIAL   PRIMARY KEY,
  player_id   UUID        NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  session_id  UUID        REFERENCES game_sessions(id) ON DELETE SET NULL,
  elo_before  INTEGER     NOT NULL,
  elo_after   INTEGER     NOT NULL,
  delta       INTEGER     NOT NULL,
  reason      VARCHAR(32) NOT NULL
              CHECK (reason IN ('session_completed', 'session_failed', 'admin_adjustment', 'decay')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_elo_history_player ON elo_history (player_id, created_at DESC);
```

Append-only audit log. Never update rows. Source of truth for ELO progression charts.

---

## Leaderboard

No separate table. Three indexed queries with a 30-second in-memory LRU cache in Node (no Redis needed at this scale):

```sql
-- Global (uncapped, top 100 by ELO)
SELECT id, username, display_name, avatar_url, current_elo
FROM players
ORDER BY current_elo DESC LIMIT 100;

-- Per-level (completed sessions only, best score per player)
SELECT gs.player_id, p.username, p.display_name, MAX(gs.score) AS best_score
FROM game_sessions gs
JOIN players p ON p.id = gs.player_id
WHERE gs.level_id = $1 AND gs.status = 'completed'
GROUP BY gs.player_id, p.username, p.display_name
ORDER BY best_score DESC LIMIT 100;

-- Classroom (per-classroom ELO, visibility-gated)
SELECT cm.player_id, p.username, p.display_name, cm.classroom_elo
FROM classroom_members cm
JOIN players p ON p.id = cm.player_id
WHERE cm.classroom_id = $1
ORDER BY cm.classroom_elo DESC LIMIT 100;
```

---

## ELO Calculation

### Unity → Server contract

Unity only sends `{ is_correct: boolean, time_taken_ms: number }` per question. Server computes all ELO logic. Unity handles question generation client-side using `question_gen_config` from the level.

### Per-answer event

```
Guard: if (correct_count + incorrect_count >= max_answers) → 409 Conflict

if is_correct:
  delta = +level.elo_gain_correct
  session.score += level.elo_gain_correct
  session.current_streak += 1
else:
  delta = -level.elo_loss_incorrect
  session.current_streak = 0

session.max_streak = max(session.max_streak, session.current_streak)
session.elo_delta += delta   -- accumulated, not committed to player yet

INSERT session_answers
UPDATE game_sessions (score, correct_count / incorrect_count, streaks, elo_delta)

Return: { is_correct, elo_delta, current_streak, current_score }
```

### Session-end transaction (completed or failed)

```sql
BEGIN;

  UPDATE game_sessions
     SET status = $status,
         elo_after = $final_global_elo,
         elo_delta = $session_elo_delta,
         ended_at = now()
   WHERE id = $session_id AND status = 'in_progress';

  UPDATE players
     SET current_elo = GREATEST(0, current_elo + $session_elo_delta),
         highest_level_unlocked = CASE
           WHEN $status = 'completed'
           THEN GREATEST(highest_level_unlocked, $next_level_id)
           ELSE highest_level_unlocked
         END,
         total_questions_answered = total_questions_answered + $total,
         total_correct            = total_correct + $correct,
         total_incorrect          = total_incorrect + $incorrect,
         longest_streak           = GREATEST(longest_streak, $max_streak),
         last_active_at           = now(),
         updated_at               = now()
   WHERE id = $player_id;

  UPDATE classroom_members cm
     SET classroom_elo = LEAST(
           COALESCE(c.elo_cap, 2147483647),
           GREATEST(0, cm.classroom_elo + $session_elo_delta)
         )
  FROM classrooms c
   WHERE cm.classroom_id = c.id AND cm.player_id = $player_id;

  INSERT INTO elo_history (player_id, session_id, elo_before, elo_after, delta, reason)
  VALUES ($player_id, $session_id, $elo_before, $final_global_elo, $session_elo_delta, $reason);

COMMIT;
```

Abandoned sessions: no ELO applied, no transaction — `UPDATE game_sessions SET status = 'abandoned'` only.

### Session outcome summary

| Status    | ELO applied             | Level unlock |
| --------- | ----------------------- | ------------ |
| completed | accumulated delta (≥ 0) | yes          |
| failed    | accumulated delta (≥ 0) | no           |
| abandoned | none                    | no           |

### Stale session janitor

Node `setInterval` at server startup, runs every 5 minutes:

```sql
UPDATE game_sessions SET status = 'abandoned'
WHERE status = 'in_progress'
  AND started_at < now() - interval '30 minutes';
```

Handles browser crash and network drop cases where the client never sends `/abandon`. No ELO applied.

---

## Web Server

### Event flow

```
POST /api/v1/sessions
    Body: { level_id }
    Returns: {
        session_id,
        level_config: {
            elo_gain_correct,
            elo_loss_incorrect,
            enemy_wave_config,
            question_gen_config,
            time_limit_seconds
        }
    }

POST /api/v1/sessions/:id/answers
    Body: {
        is_correct,
        time_taken_ms
    }
    Returns: {
        is_correct,
        elo_delta,
        current_streak,
        current_score
    }

POST /api/v1/sessions/:id/complete | /fail | /abandon
  Returns: { final_elo, elo_delta, new_levels_unlocked }
```

WebSocket is not used. Question answer frequency is too low (a child solving math) to justify a persistent connection. WebSocket can be added later if a real-time classroom monitoring dashboard is needed.

`sendBeacon` handles the `/abandon` call on page unload.

### Authentication

- OAuth (Google) or password login
- Sessions via `express-session` (cookie-based, no JWT / refresh token management)
- Unity WebGL runs same-origin — session cookie included automatically on all `fetch` calls with `credentials: 'include'`

### Authorization (RBAC)

Roles seeded from the `roles` table: `student`, `teacher`, `admin`. Checked in `authorize.ts` middleware by `roles.name`.

---

## API Design

All endpoints under `/api/v1`.

### Auth

```
POST /auth/register                 { username, email, password, display_name? }
POST /auth/login                    { email, password }
POST /auth/logout
GET  /auth/oauth/google
GET  /auth/oauth/google/callback
GET  /auth/me
```

### Players

```
GET   /players/:id                  public profile
GET   /players/:id/stats            elo_history + sessions (self | teacher of class | admin)
GET   /players/:id/elo-history      { from?, to?, limit? }
PATCH /players/:id                  { display_name?, avatar_url?, username? }
```

### Levels

```
GET    /levels                      list with player unlock status
GET    /levels/:id                  detail + question_gen_config for Unity
POST   /levels                      admin only
PUT    /levels/:id                  admin only
DELETE /levels/:id                  admin only (soft delete via is_active = false)
```

### Sessions

```
POST /sessions                      { level_id }
POST /sessions/:id/answers          { is_correct, time_taken_ms }
POST /sessions/:id/complete
POST /sessions/:id/fail
POST /sessions/:id/abandon
GET  /sessions/:id
```

### Leaderboard

```
GET /leaderboard/global             30s cache
GET /leaderboard/levels/:id         30s cache
GET /leaderboard/global/me          caller's rank
GET /leaderboard/classrooms/:id     visibility-gated
```

### Classrooms

```
POST   /classrooms                  { name, description, visibility, elo_cap? }  teacher only
GET    /classrooms                  teacher: own classes; admin: all
GET    /classrooms/:id              detail + members
PATCH  /classrooms/:id              { name, description, visibility, elo_cap? }  teacher only
DELETE /classrooms/:id              teacher only (soft delete)
GET    /classrooms/:id/members      student list with stats
POST   /classrooms/join             { invite_code }  student joins
DELETE /classrooms/:id/leave        student leaves
```

### Admin

```
GET   /admin/players                { role?, search?, limit, offset }
PATCH /admin/players/:id/role       { role }
PATCH /admin/players/:id/elo        { elo, reason }
GET   /admin/sessions               { player_id?, level_id?, status?, from?, to? }
GET   /admin/stats
```

---

## Deployment

### Local

Docker Compose: `postgres:16-alpine` + `server` (ts-node-dev hot reload) + `web` (Vite dev server)

### CI — GitHub Actions

`pr-check.yml` on every PR to `main`:

- `npm run build` (tsc typecheck)
- ESLint
- Jest unit tests

`deploy.yml` on merge to `main`:

- SSH into EC2, pull latest image, run `docker compose up -d`
- Run DB migrations after containers are up

### CD — AWS EC2

Single EC2 t3.micro (Ubuntu) running Docker Compose. Everything on one machine.

```
EC2 t3.micro
├── Nginx               reverse proxy on port 80/443 + serves web static files
├── server container    Express app
└── postgres container  Postgres with EBS volume mount for data persistence
```

**SSL:** Certbot (Let's Encrypt) on the EC2, free. Nginx handles termination.

**Secrets management:**

No AWS Secrets Manager (costs money). Use a `.env` file on the EC2 directly:

```bash
# SSH into EC2 once on first setup
ssh ubuntu@<your-ec2-ip>
nano /app/.env          # fill in values manually
```

`.env` is never committed to git. Docker Compose reads it via `env_file: .env`.

GitHub Actions needs two secrets (stored in GitHub → Settings → Secrets, not AWS):

- `EC2_HOST` — public IP of the EC2
- `EC2_SSH_KEY` — private SSH key for the EC2 instance

Deploy workflow:

```yaml
- name: Deploy
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.EC2_HOST }}
    username: ubuntu
    key: ${{ secrets.EC2_SSH_KEY }}
    script: |
      cd /app
      git pull origin main
      docker compose pull
      docker compose up -d
      npm run db:migrate
```

**EC2 security group rules:**

- Port 22 (SSH): your IP only
- Port 80 (HTTP): 0.0.0.0/0
- Port 443 (HTTPS): 0.0.0.0/0
- Port 5432 (Postgres): blocked — only accessible inside the EC2

Two environments only: local (`docker-compose`) + prod (EC2 on AWS).

### Migrations

`node-pg-migrate` with numbered SQL files in `apps/server/src/db/migrations/`.

Tracking table (auto-created on first run):

```sql
CREATE TABLE pgmigrations (
  id      SERIAL       PRIMARY KEY,
  name    VARCHAR(255) NOT NULL,
  run_on  TIMESTAMPTZ  NOT NULL
);
```

npm scripts:

```json
"db:migrate":  "node-pg-migrate up",
"db:rollback": "node-pg-migrate down 1"
```

In prod CI, `db:migrate` runs after `docker compose up -d`. If it fails, the deploy is marked failed — roll back with `npm run db:rollback` and redeploy the previous image.

# Appendix

- JSONB: for every json be we should have a schema in root

```json
{
    "schema": 1,
    "data":{
        "foo": []
        "bar": "string"

    }
}
```
