# Leaderboard Route — Flowchart

All endpoints require `authenticate`. Cache clear requires `authorize("admin:full")`.

## Endpoints
- `GET /global` — global leaderboard
- `GET /levels/:id` — level leaderboard
- `GET /classrooms/:id` — classroom leaderboard
- `DELETE /cache/clear` — clear all cache (admin)

---

## GET /global

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /global]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| PAG[parsePagination cursor + limit]
    PAG --> SVC[leaderboardService.getGlobal pagination]
    SVC --> CACHE{cache hit?}
    CACHE -->|hit| LOG_HIT[log cache:hit]
    LOG_HIT --> R200[200 PaginatedData GlobalLeaderboardRow]
    CACHE -->|miss| LOG_MISS[log cache:miss]
    LOG_MISS --> DB[query GlobalLeaderboardRow array]
    DB --> SET[cache.set cacheKey + data]
    SET --> R200
```

## GET /levels/:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /levels/:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| PAG[parsePagination + parsePeriod]
    PAG --> SVC[leaderboardService.getByLevel levelId + pagination + period]
    SVC --> CACHE{cache hit?}
    CACHE -->|hit| LOG_HIT[log cache:hit]
    LOG_HIT --> R200[200 PaginatedData LevelLeaderboardRow]
    CACHE -->|miss| LOG_MISS[log cache:miss]
    LOG_MISS --> DATE[periodToStartDate period]
    DATE --> DB[query LevelLeaderboardRow array]
    DB --> SET[cache.set cacheKey + data]
    SET --> R200
```

## GET /classrooms/:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /classrooms/:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| PAG[parsePagination + parsePeriod]
    PAG --> SVC[leaderboardService.getByClassroom classroomId + pagination + period]
    SVC --> CACHE{cache hit?}
    CACHE -->|hit| LOG_HIT[log cache:hit]
    LOG_HIT --> R200[200 PaginatedData ClassroomLeaderboardRow]
    CACHE -->|miss| LOG_MISS[log cache:miss]
    LOG_MISS --> DATE[periodToStartDate period]
    DATE --> DB[query ClassroomLeaderboardRow array]
    DB --> SET[cache.set cacheKey + data]
    SET --> R200
```

## DELETE /cache/clear

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([DELETE /cache/clear]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize admin:full}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| SVC[leaderboardService.invalidateAll]
    SVC --> CLEAR[leaderboardCache.clear]
    CLEAR --> LOG[log cache:pruned]
    LOG --> SERIAL[leaderboardCache.serialize]
    SERIAL --> R200[200 CacheSnapshot]
```
