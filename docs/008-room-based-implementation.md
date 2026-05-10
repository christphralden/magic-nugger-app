# Room-Based Multiplayer — Architecture

## Overview

A `room` is an ephemeral intermediary between persistent contexts (classrooms, PVP invites) and individual game sessions. It groups players, enforces a shared level, and becomes the unit for post-game leaderboard queries.

Multiplayer in this system is **score comparison only**. Unity is unaware of rooms — it only ever receives a `game_session_id` and plays a single-player session. The room groups those sessions together.

---

## ERD

### New tables

**`rooms`**
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | `gen_random_uuid()` |
| host_id | UUID FK → players | Room creator |
| classroom_id | UUID FK → classrooms | Null for PVP rooms |
| level_id | INT FK → levels | Shared level for all members |
| type | VARCHAR(16) | `'classroom'` or `'pvp'` |
| status | VARCHAR(16) | `'waiting'` → `'in_progress'` → `'completed'` / `'cancelled'` |
| invite_code | VARCHAR(16) UNIQUE | 8-char uppercase UUID slice |
| max_players | INT | Default 10, range 2–50 |
| started_at | TIMESTAMPTZ | Set on start |
| ended_at | TIMESTAMPTZ | Set on complete/cancel |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

**`room_members`**
| Column | Type | Notes |
|--------|------|-------|
| room_id | UUID FK → rooms | Cascade delete |
| player_id | UUID FK → players | |
| game_session_id | UUID FK → game_sessions | Null until player starts their session; SET NULL on delete |
| joined_at | TIMESTAMPTZ | |
| PK | (room_id, player_id) | |

### Modified tables

**`game_sessions`** — add `room_id UUID FK → rooms ON DELETE SET NULL` (nullable, all existing rows unaffected)

---

## Room Lifecycle

```
waiting ──────────────────────────────────────────► cancelled
   │   host cancels / teacher cancels classroom room    ▲
   │                                                    │
   │ host calls POST /rooms/:id/start                   │ any state
   ▼                                                    │
in_progress ─────────────────────────────────────────► cancelled
   │
   │ all members done  OR  host calls POST /rooms/:id/end
   ▼
completed
```

**Atomic transition guard**: `UPDATE rooms SET status='in_progress' WHERE id=$1 AND status='waiting' RETURNING id` — if no row returned, room already moved (409).

**Stale room cleanup**: A cron job (`db/cron/room-cleanup.mjs`) cancels `waiting` rooms older than 2 hours and `in_progress` rooms older than 4 hours.

---

## Permissions

New permissions granted to both `student` and `teacher` roles:

| Permission | Who uses it |
|-----------|-------------|
| `room:create` | Any authenticated player (PVP); teacher (classroom room) |
| `room:join` | Any authenticated player |
| `room:start` | Host only (enforced in service, not middleware) |
| `room:end` | Host only |
| `room:cancel` | Host or classroom teacher |

Ownership checks (host vs. non-host) happen in the service layer, matching the pattern already used in `classrooms.ts`.

---

## API Routes

All under `/api/v1/rooms`, all require `authenticate`.

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/` | Create PVP room. Host auto-joins. Returns 201 + Room. |
| `POST` | `/classroom` | Create classroom room. Validates teacher owns classroom. Blocks duplicate active room per classroom (409). |
| `POST` | `/join` | Join room by `invite_code`. Only `waiting` rooms. Max-player check. |
| `GET` | `/:id` | Room + member list with session statuses. **Used for lobby polling.** |
| `GET` | `/` | Active rooms where current user is member or host. |
| `POST` | `/:id/start` | Transition room to `in_progress`. Host only. |
| `POST` | `/:id/end` | Mark room completed. Host only. |
| `DELETE` | `/:id` | Cancel room. Host or owning teacher. |

**Leaderboard**: `GET /api/v1/leaderboard/rooms/:id` (permission: `leaderboard:read`)

---

## Game Session Integration

When `POST /api/v1/game` is called with `{ level_id, room_id }`:
1. Room must be `in_progress` — 409 if not.
2. Player must be a `room_members` row for that room.
3. Session created with `game_sessions.room_id` set.
4. `room_members.game_session_id` updated within the same transaction.

Resumable session behaviour is unchanged. If a player resumes (within 30-min window), the existing session is returned. If outside the window, the old session is abandoned and a new one is created — `room_members.game_session_id` updates to the new session.

When a session ends (`POST /game/:id/end` or `/:id/fail`), `roomService.checkAndCompleteRoom()` is called. If all room members have non-`in_progress` sessions, the room is marked `completed` automatically.

---

## Leaderboard

### Per-room query

```sql
SELECT
  rm.player_id,
  p.username,
  p.display_name,
  p.avatar_url,
  rm.game_session_id,
  gs.score,
  gs.elo_delta,
  gs.correct_count,
  gs.incorrect_count,
  gs.max_streak,
  gs.status          AS session_status,
  gs.ended_at        AS finished_at
FROM room_members rm
JOIN players p ON p.id = rm.player_id
LEFT JOIN game_sessions gs ON gs.id = rm.game_session_id
WHERE rm.room_id = $1
ORDER BY
  CASE WHEN gs.status IN ('completed', 'failed') THEN 0 ELSE 1 END,
  gs.score DESC NULLS LAST,
  rm.joined_at ASC;
```

Finished players sort first by score. Players who haven't started (null session) sort last. No caching — rooms are short-lived.

### Classroom leaderboard

Unchanged. Still ranks by `classroom_elo` from `classroom_members` — an independent metric from ELO earned in room sessions.

---

## Abandoned Session in Room

- One player abandoning does not affect others in the room.
- `room_members.game_session_id` still points to the abandoned session — the player's score and stats are visible in the leaderboard with `session_status = 'abandoned'`.
- If the player starts a new session in the same room, `game_session_id` is updated atomically within the new session creation transaction.

---

## Unity Integration (unchanged)

Unity is given a `game_session_id` by the frontend. It calls:
- `POST /game/:id/answer` — per question
- `POST /game/:id/end` or `POST /game/:id/fail` — on completion

Unity does not know about rooms. All room logic lives in the FE and API layer.

---

## Implementation Files

| File | Status | Change |
|------|--------|--------|
| `db/migrations/apply/202605100001_create_rooms.sql` | new | |
| `db/migrations/apply/202605100002_create_room_members.sql` | new | |
| `db/migrations/apply/202605100003_add_room_id_to_game_sessions.sql` | new | |
| `db/migrations/apply/202605100004_add_room_permissions.sql` | new | |
| `shared/src/types/room.types.ts` | new | Room, RoomMember, RoomStatus, request/response schemas |
| `shared/src/types/session.types.ts` | modify | Add `room_id` to GameSession + RequestCreateGameSession |
| `web-server/src/services/room.service.ts` | new | create, join, getById, getWithMembers, start, end, cancel, linkMemberSession, checkAndCompleteRoom |
| `web-server/src/services/game-session.service.ts` | modify | Add `roomId?` to create(), add `room_id` to SELECTs |
| `web-server/src/services/game.service.ts` | modify | Accept `roomId?`, validate room status, call linkMemberSession + checkAndCompleteRoom |
| `web-server/src/services/leaderboard.service.ts` | modify | Add `getByRoom(roomId)` |
| `web-server/src/routes/rooms.ts` | new | All room endpoints |
| `web-server/src/routes/game.ts` | modify | Thread `room_id` from body |
| `web-server/src/routes/leaderboard.ts` | modify | Add `GET /rooms/:id` |
| `web-server/src/app.ts` | modify | Mount roomsRouter, uncomment classroomsRouter |
| `db/cron/room-cleanup.mjs` | new | Cancel stale rooms |
