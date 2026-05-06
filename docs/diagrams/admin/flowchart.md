# Admin Route — Flowchart

All endpoints require: `authenticate` + `authorize("admin:full")`

## Endpoints
- `GET /players`
- `PATCH /players/:id/role`
- `PATCH /players/:id/elo`
- `GET /game-sessions/active`
- `GET /game-sessions`
- `GET /stats`

---

## GET /players

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /players]) --> AUTH{authenticate + authorize admin:full}
    AUTH -->|fail| E401[401/403]
    AUTH -->|ok| PAG[parsePagination cursor + limit]
    PAG --> DB[query Player array]
    DB --> LOG[log admin:player_viewed]
    LOG --> R200[200 PaginatedData Player]
```

## PATCH /players/:id/role

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([PATCH /players/:id/role]) --> AUTH{authenticate + authorize admin:full}
    AUTH -->|fail| E401[401/403]
    AUTH -->|ok| V{validate role}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| DB[query Player]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| LOG[log admin:role_changed]
    LOG --> R200[200 null]
```

## PATCH /players/:id/elo

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([PATCH /players/:id/elo]) --> AUTH{authenticate + authorize admin:full}
    AUTH -->|fail| E401[401/403]
    AUTH -->|ok| V{validate RequestAdjustEloSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| DB1[query Player]
    DB1 --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| TX[tx: query Player + EloHistory]
    TX --> CACHE[leaderboardService.invalidateGlobal]
    CACHE --> LOG1[log admin:elo_adjusted]
    LOG1 --> LOG2[log elo:admin_adjusted]
    LOG2 --> R200[200 null]
```

## GET /game-sessions/active

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /game-sessions/active]) --> AUTH{authenticate + authorize admin:full}
    AUTH -->|fail| E401[401/403]
    AUTH -->|ok| DB[query GameSession array status=in_progress]
    DB --> LOG[log admin:sessions_viewed]
    LOG --> R200[200 GameSession array]
```

## GET /game-sessions

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /game-sessions]) --> AUTH{authenticate + authorize admin:full}
    AUTH -->|fail| E401[401/403]
    AUTH -->|ok| PAG[parsePagination query]
    PAG --> DB[query GameSession array with filters]
    DB --> LOG[log admin:sessions_viewed]
    LOG --> R200[200 PaginatedData GameSession]
```

## GET /stats

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /stats]) --> AUTH{authenticate + authorize admin:full}
    AUTH -->|fail| E401[401/403]
    AUTH -->|ok| DB[query Stats]
    DB --> R200[200 Stats]
```
