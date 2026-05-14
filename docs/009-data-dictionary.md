# Data Dictionary

Generated from migrations. Last updated: 2026-05-14.

**Database:** PostgreSQL 16  
**Schemas:** `public`, `audit`  
**Partitioning:** `session_answers`, `elo_history`, `audit.audit_events`, `audit.log_events` use weekly RANGE partitions managed by `pg_partman`.

---

## Table of Contents

| Table | Schema | Description |
|---|---|---|
| [permissions](#permissions) | public | Named permission strings for RBAC |
| [roles](#roles) | public | User roles (student, teacher, admin) |
| [role_permissions](#role_permissions) | public | Role-to-permission assignments |
| [players](#players) | public | Player accounts and stats |
| [levels](#levels) | public | Game level definitions |
| [levels_unlocked](#levels_unlocked) | public | Per-player level unlock log |
| [classrooms](#classrooms) | public | Teacher-managed classrooms |
| [classroom_members](#classroom_members) | public | Classroom enrollment and scoped ELO |
| [game_sessions](#game_sessions) | public | Individual play sessions |
| [session_answers](#session_answers) | public | Per-answer events within a session (partitioned) |
| [elo_history](#elo_history) | public | Append-only ELO change log (partitioned) |
| [session](#session) | public | Express session store (connect-pg-simple) |
| [audit.audit_events](#auditaudit_events) | audit | HTTP request audit log (partitioned) |
| [audit.log_events](#auditlog_events) | audit | Application event log (partitioned) |

---

## permissions

**Purpose:** Stores the canonical set of permission strings used for RBAC. Permissions follow a `domain:action` naming convention.

**Migration:** `202605020001_create_permissions`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `SERIAL` | NO | auto | Surrogate primary key |
| `name` | `VARCHAR(64)` | NO | — | Unique permission string |

**Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE (name)`

**Seeded values:**

| Permission | Applies to |
|---|---|
| `player:read` | Read player profiles |
| `player:update` | Update own profile |
| `session:create` | Start a game session |
| `session:update` | Update session state |
| `classroom:create` | Create a classroom |
| `classroom:update` | Update classroom settings |
| `classroom:delete` | Delete a classroom |
| `classroom:read` | View classroom details |
| `classroom:join` | Join a classroom via invite code |
| `classroom:leave` | Leave a classroom |
| `leaderboard:read` | View leaderboards |
| `level:create` | Create game levels |
| `level:update` | Update game levels |
| `level:delete` | Delete game levels |
| `admin:full` | Full admin access |
| `*` | Wildcard — all permissions |

---

## roles

**Purpose:** Defines user roles. Each player has exactly one role. Three roles are seeded at migration time.

**Migration:** `202605020002_create_roles`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `SERIAL` | NO | auto | Surrogate primary key |
| `name` | `VARCHAR(32)` | NO | — | Unique role name |
| `description` | `TEXT` | YES | — | Human-readable description |

**Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE (name)`

**Seeded values:**

| id | name | description |
|---|---|---|
| 1 | `student` | Default student role |
| 2 | `teacher` | Teacher role |
| 3 | `admin` | Admin with full access |

---

## role_permissions

**Purpose:** Many-to-many join table assigning permissions to roles. Seeded at migration time.

**Migration:** `202605020003_create_role_permissions`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `role_id` | `INTEGER` | NO | — | FK → roles.id |
| `permission_id` | `INTEGER` | NO | — | FK → permissions.id |

**Constraints:**
- `PRIMARY KEY (role_id, permission_id)`
- `FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE`
- `FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE`

**Seeded assignments:**

| Role | Permissions |
|---|---|
| `student` | `player:read`, `player:update`, `session:create`, `session:update`, `classroom:join`, `classroom:leave`, `leaderboard:read` |
| `teacher` | `player:read`, `player:update`, `session:create`, `session:update`, `classroom:create`, `classroom:update`, `classroom:delete`, `classroom:read`, `leaderboard:read` |
| `admin` | `*`, `admin:full` |

---

## players

**Purpose:** Core player record. Stores authentication credentials, profile info, and global aggregate statistics. Supports both Google OAuth and local password authentication.

**Migrations:** `202605020004_create_players`, `202605110001_add_player_profile_fields`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `UUID` | NO | `gen_random_uuid()` | Primary key |
| `username` | `VARCHAR(32)` | NO | — | Unique display handle |
| `display_name` | `VARCHAR(64)` | YES | — | Optional friendly name |
| `email` | `VARCHAR(255)` | NO | — | Unique email address |
| `avatar_url` | `TEXT` | YES | — | URL to profile image |
| `role_id` | `INTEGER` | NO | `1` (student) | FK → roles.id |
| `oauth_provider` | `VARCHAR(32)` | YES | — | OAuth provider name (e.g. `google`) |
| `oauth_id` | `VARCHAR(255)` | YES | — | Provider-issued user ID |
| `password_hash` | `TEXT` | YES | — | Bcrypt password hash |
| `current_elo` | `INTEGER` | NO | `0` | Global ELO rating (uncapped) |
| `total_questions_answered` | `INTEGER` | NO | `0` | Lifetime questions answered |
| `total_correct` | `INTEGER` | NO | `0` | Lifetime correct answers |
| `total_incorrect` | `INTEGER` | NO | `0` | Lifetime incorrect answers |
| `longest_streak` | `INTEGER` | NO | `0` | Longest consecutive correct answer streak |
| `age` | `SMALLINT` | YES | — | Player age |
| `grade` | `SMALLINT` | YES | — | School grade |
| `guardian_email` | `VARCHAR(255)` | YES | — | Guardian contact email |
| `created_at` | `TIMESTAMPTZ` | NO | `now()` | Account creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | NO | `now()` | Last profile update timestamp |
| `last_active_at` | `TIMESTAMPTZ` | YES | — | Last session start timestamp |

**Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE (username)`
- `UNIQUE (email)`
- `CHECK oauth_or_password`: `(oauth_provider IS NOT NULL AND oauth_id IS NOT NULL) OR (password_hash IS NOT NULL)` — ensures every player has at least one auth method
- `CHECK (age > 0)`
- `CHECK (grade > 0)`
- `FOREIGN KEY (role_id) REFERENCES roles(id)`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_players_elo` | `current_elo DESC` | Global leaderboard ordering |
| `idx_players_email` | `email` | Auth lookup by email |
| `idx_players_oauth` | `oauth_provider, oauth_id` | Partial: `WHERE oauth_provider IS NOT NULL` |
| `idx_players_created` | `created_at DESC` | Admin pagination |

---

## levels

**Purpose:** Defines each playable game level. The primary key is `name` (the level's display name). The `id` column is a SERIAL integer with a UNIQUE constraint used as the FK target from `game_sessions` and `levels_unlocked`. JSONB configs are passed verbatim to the Unity client; the server only validates question count from `question_gen_config`.

**Migration:** `202605020005_create_levels`, `202605110003_drop_levels_max_score`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `name` | `VARCHAR(64)` | NO | — | **Primary key** — level display name |
| `id` | `SERIAL` | NO | auto | Unique integer, used as FK target |
| `description` | `TEXT` | YES | — | Level description |
| `order_index` | `INTEGER` | NO | — | Display ordering (not unique) |
| `child_levels` | `TEXT[]` | YES | — | Array of child level names (DAG structure) |
| `elo_min` | `INTEGER` | NO | `0` | Minimum global ELO required to play |
| `elo_gain_correct` | `INTEGER` | NO | `15` | ELO awarded per correct answer |
| `elo_loss_incorrect` | `INTEGER` | NO | `5` | ELO deducted per incorrect answer |
| `time_limit_seconds` | `INTEGER` | YES | — | Per-question time limit; `NULL` = unlimited |
| `enemy_wave_config` | `JSONB` | NO | `{}` | Unity enemy wave parameters (opaque to server) |
| `question_gen_config` | `JSONB` | NO | `{}` | Question generation parameters (opaque to server, except question count) |
| `is_active` | `BOOLEAN` | NO | `true` | Soft-delete flag |
| `created_at` | `TIMESTAMPTZ` | NO | `now()` | Creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | NO | `now()` | Last update timestamp |

**Constraints:**
- `PRIMARY KEY (name)`
- `UNIQUE (id)`

---

## levels_unlocked

**Purpose:** Records which levels each player has unlocked. Acts as a many-to-many pivot between `players` and `levels`. Append-only; rows are inserted when a level is first completed.

**Migration:** `202605110002_create_levels_unlocked`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `player_id` | `UUID` | NO | — | FK → players.id |
| `level_id` | `INTEGER` | NO | — | FK → levels.id |
| `unlocked_at` | `TIMESTAMPTZ` | NO | `now()` | Timestamp of unlock |

**Constraints:**
- `PRIMARY KEY (player_id, level_id)`
- `FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE`
- `FOREIGN KEY (level_id) REFERENCES levels(id) ON DELETE CASCADE`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_levels_unlocked_player` | `player_id` | Per-player unlock lookup |

---

## classrooms

**Purpose:** Teacher-managed groups of students. Controls ELO range for the classroom leaderboard via `starting_elo` (floor) and `elo_cap` (ceiling). Students join via a unique `invite_code`.

**Migration:** `202605020006_create_classrooms`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `UUID` | NO | `gen_random_uuid()` | Primary key |
| `name` | `VARCHAR(128)` | NO | — | Classroom display name |
| `description` | `TEXT` | YES | — | Optional description |
| `teacher_id` | `UUID` | NO | — | FK → players.id (owning teacher) |
| `visibility` | `VARCHAR(16)` | NO | `'private'` | `'private'` or `'public'` |
| `starting_elo` | `INTEGER` | NO | `0` | ELO floor for classroom leaderboard |
| `elo_cap` | `INTEGER` | YES | — | ELO ceiling; `NULL` = no cap |
| `invite_code` | `VARCHAR(16)` | NO | — | Unique join code |
| `is_active` | `BOOLEAN` | NO | `true` | Soft-delete flag |
| `created_at` | `TIMESTAMPTZ` | NO | `now()` | Creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | NO | `now()` | Last update timestamp |

**Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE (invite_code)`
- `CHECK visibility IN ('private', 'public')`
- `CHECK elo_cap_above_floor`: `elo_cap IS NULL OR elo_cap > starting_elo`
- `FOREIGN KEY (teacher_id) REFERENCES players(id) ON DELETE CASCADE`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_classrooms_teacher` | `teacher_id` | Teacher's classroom list |
| `idx_classrooms_invite` | `invite_code` | Join-by-code lookup |

---

## classroom_members

**Purpose:** Tracks student enrollment in classrooms. Stores a per-classroom ELO (`classroom_elo`) that is floored at `classrooms.starting_elo` and optionally capped at `classrooms.elo_cap`. This is independent of the player's global `current_elo`.

**Migration:** `202605020007_create_classroom_members`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `classroom_id` | `UUID` | NO | — | FK → classrooms.id |
| `player_id` | `UUID` | NO | — | FK → players.id |
| `classroom_elo` | `INTEGER` | NO | — | Student's ELO within this classroom |
| `joined_at` | `TIMESTAMPTZ` | NO | `now()` | Enrollment timestamp |

**Constraints:**
- `PRIMARY KEY (classroom_id, player_id)`
- `FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE`
- `FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_members_player` | `player_id` | Player's classroom list |

---

## game_sessions

**Purpose:** Records each play session. Captures ELO state before and after, streaks, and answer counts. Status transitions: `in_progress` → `completed` | `failed` | `abandoned`. A cron job marks stale sessions (>30 min inactive) as `abandoned`.

**Migrations:** `202605020008_create_game_sessions`, `202605070002_create_admin_indexes`, `202605120001_drop_game_sessions_max_answers`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `UUID` | NO | `gen_random_uuid()` | Primary key |
| `player_id` | `UUID` | NO | — | FK → players.id |
| `level_id` | `INTEGER` | NO | — | FK → levels.id |
| `status` | `VARCHAR(16)` | NO | `'in_progress'` | Session state (see enum below) |
| `score` | `INTEGER` | NO | `0` | Accumulated ELO delta during session |
| `elo_before` | `INTEGER` | NO | — | Player's global ELO at session start |
| `elo_after` | `INTEGER` | YES | — | Player's global ELO at session end |
| `elo_delta` | `INTEGER` | YES | — | Net ELO change for the session |
| `correct_count` | `INTEGER` | NO | `0` | Total correct answers |
| `incorrect_count` | `INTEGER` | NO | `0` | Total incorrect answers |
| `max_streak` | `INTEGER` | NO | `0` | Best consecutive correct streak |
| `current_streak` | `INTEGER` | NO | `0` | Current streak (in-flight) |
| `started_at` | `TIMESTAMPTZ` | NO | `now()` | Session start time |
| `ended_at` | `TIMESTAMPTZ` | YES | — | Session end time |
| `client_ip` | `INET` | YES | — | Player's IP address |
| `user_agent` | `TEXT` | YES | — | Player's user agent string |

**Status enum:**

| Value | Meaning |
|---|---|
| `in_progress` | Session is active |
| `completed` | All questions answered successfully |
| `failed` | Player failed (e.g. too many wrong answers) |
| `abandoned` | Session timed out or was explicitly abandoned |

**Constraints:**
- `PRIMARY KEY (id)`
- `CHECK status IN ('in_progress', 'completed', 'failed', 'abandoned')`
- `FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE`
- `FOREIGN KEY (level_id) REFERENCES levels(id)`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_sessions_player` | `player_id, started_at DESC` | Player session history |
| `idx_sessions_level` | `level_id, score DESC` | Partial: `WHERE status = 'completed'`; level leaderboard |
| `idx_sessions_started` | `started_at DESC` | Admin pagination |
| `idx_sessions_status_started` | `status, started_at DESC` | Admin filtering by status |

---

## session_answers

**Purpose:** Logs every individual answer submitted during a game session. High-volume table — partitioned weekly by `answered_at` using `pg_partman`. The composite PK `(id, answered_at)` is required by PostgreSQL for range-partitioned tables.

**Migrations:** `202605020009_create_session_answers`, `202605080001_partition_session_answers`

**Partitioning:** `RANGE (answered_at)` — 1-week intervals, 3 partitions pre-created

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `BIGSERIAL` | NO | auto | Surrogate key (part of composite PK) |
| `session_id` | `UUID` | NO | — | FK → game_sessions.id |
| `is_correct` | `BOOLEAN` | NO | — | Whether the answer was correct |
| `elo_delta` | `INTEGER` | NO | — | ELO change for this answer (positive or negative) |
| `time_taken_ms` | `INTEGER` | YES | — | Time to answer in milliseconds |
| `answered_at` | `TIMESTAMPTZ` | NO | `now()` | Answer timestamp; partition column |

**Constraints:**
- `PRIMARY KEY (id, answered_at)` — composite required for partitioning
- `FOREIGN KEY (session_id) REFERENCES game_sessions(id) ON DELETE CASCADE`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_answers_session` | `session_id, answered_at` | Per-session answer lookup |

---

## elo_history

**Purpose:** Append-only audit log of every ELO change per player. Never updated after insert. Partitioned weekly by `created_at` using `pg_partman`.

**Migrations:** `202605020010_create_elo_history`, `202605080002_partition_elo_history`, `202605090001_add_session_abandoned_reason`

**Partitioning:** `RANGE (created_at)` — 1-week intervals, 3 partitions pre-created

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `BIGSERIAL` | NO | auto | Surrogate key (part of composite PK) |
| `player_id` | `UUID` | NO | — | FK → players.id |
| `session_id` | `UUID` | YES | — | FK → game_sessions.id (`ON DELETE SET NULL`) |
| `elo_before` | `INTEGER` | NO | — | ELO value before change |
| `elo_after` | `INTEGER` | NO | — | ELO value after change |
| `delta` | `INTEGER` | NO | — | Signed ELO change (`elo_after - elo_before`) |
| `reason` | `VARCHAR(32)` | NO | — | Cause of change (see enum below) |
| `created_at` | `TIMESTAMPTZ` | NO | `now()` | Change timestamp; partition column |

**Reason enum:**

| Value | Meaning |
|---|---|
| `session_completed` | Session finished successfully |
| `session_failed` | Session ended in failure |
| `session_abandoned` | Session timed out or was abandoned |
| `admin_adjustment` | Manual ELO correction by admin |
| `decay` | Automatic ELO decay (scheduled) |

**Constraints:**
- `PRIMARY KEY (id, created_at)` — composite required for partitioning
- `CHECK reason IN ('session_completed', 'session_failed', 'session_abandoned', 'admin_adjustment', 'decay')`
- `FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE`
- `FOREIGN KEY (session_id) REFERENCES game_sessions(id) ON DELETE SET NULL`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_elo_history_player` | `player_id, created_at DESC` | Per-player ELO timeline |

---

## session

**Purpose:** Express session persistence table managed by `connect-pg-simple`. Stores serialized session data keyed by session ID. Not part of the application domain model.

**Migration:** `202605020011_create_pg_session`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `sid` | `VARCHAR` | NO | — | Session ID (primary key) |
| `sess` | `JSON` | NO | — | Serialized session payload |
| `expire` | `TIMESTAMP(6)` | NO | — | Expiry time for session garbage collection |

**Constraints:**
- `PRIMARY KEY (sid)` — `NOT DEFERRABLE INITIALLY IMMEDIATE`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `IDX_session_expire` | `expire` | Enables efficient cleanup of expired sessions |

---

## audit.audit_events

**Purpose:** Records every inbound HTTP request for security auditing. One row per request. Partitioned weekly by `created_at` using `pg_partman`. The `app` database role has INSERT-only access; SELECT/DELETE is restricted to admin tooling.

**Migrations:** `202605020013_create_audit_events`, `202605060001_update_audit_events_http_method`, `202605070003_update_audit_partition_interval`

**Partitioning:** `RANGE (created_at)` — 1-week intervals, 3 partitions pre-created

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `UUID` | NO | `gen_random_uuid()` | Row identifier (part of composite PK) |
| `user_id` | `UUID` | YES | — | FK → players.id (`ON DELETE SET NULL`); `NULL` for unauthenticated requests |
| `url` | `VARCHAR(255)` | NO | — | Request path |
| `status_code` | `SMALLINT` | NO | — | HTTP response status code |
| `http_method` | `VARCHAR(10)` | YES | — | HTTP verb (`GET`, `POST`, etc.) |
| `ip_address` | `INET` | YES | — | Client IP address |
| `user_agent` | `TEXT` | YES | — | Client user agent string |
| `metadata` | `JSONB` | YES | — | Additional request context |
| `created_at` | `TIMESTAMPTZ` | NO | `now()` | Request timestamp; partition column |

**Constraints:**
- `PRIMARY KEY (id, created_at)` — composite required for partitioning
- `FOREIGN KEY (user_id) REFERENCES players(id) ON DELETE SET NULL`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_audit_events_user_id` | `user_id` | Per-user audit trail |
| `idx_audit_events_created_at` | `created_at DESC` | Time-range queries |
| `idx_audit_events_url` | `url` | Filter by endpoint |
| `idx_audit_events_status_code` | `status_code` | Filter by response status |

---

## audit.log_events

**Purpose:** Application-level structured event log (errors, warnings, notable events). Distinct from `audit_events` (which logs every HTTP request). Partitioned weekly by `created_at` using `pg_partman`.

**Migrations:** `202605070001_create_log_events`, `202605080003_update_log_events_description`

**Partitioning:** `RANGE (created_at)` — 1-week intervals, 3 partitions pre-created

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `UUID` | NO | `gen_random_uuid()` | Row identifier (part of composite PK) |
| `user_id` | `UUID` | YES | — | FK → players.id (`ON DELETE SET NULL`); `NULL` for system events |
| `event` | `VARCHAR(255)` | NO | — | Event name or type identifier |
| `level` | `VARCHAR(16)` | NO | `'info'` | Severity level (see enum below) |
| `metadata` | `JSONB` | YES | — | Structured event payload |
| `description` | `TEXT` | YES | — | Human-readable event description |
| `created_at` | `TIMESTAMPTZ` | NO | `now()` | Event timestamp; partition column |

**Level enum:**

| Value | Meaning |
|---|---|
| `info` | Informational — routine events |
| `warning` | Recoverable abnormality |
| `error` | Application error |
| `fatal` | Critical failure |

**Constraints:**
- `PRIMARY KEY (id, created_at)` — composite required for partitioning
- `CHECK level IN ('info', 'warning', 'error', 'fatal')`
- `FOREIGN KEY (user_id) REFERENCES players(id) ON DELETE SET NULL`

**Indexes:**

| Name | Columns | Notes |
|---|---|---|
| `idx_log_events_event` | `event` | Filter by event type |
| `idx_log_events_created_at` | `created_at DESC` | Time-range queries |
| `idx_log_events_level` | `level` | Filter by severity |
| `idx_log_events_user_id` | `user_id` | Per-user event history |
