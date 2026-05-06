# Leaderboard Route — Sequence Diagrams

All endpoints require `authenticate`. Cache clear requires `authorize("admin:full")`.

## Endpoints
- `GET /global` — global leaderboard
- `GET /levels/:id` — level leaderboard
- `GET /classrooms/:id` — classroom leaderboard
- `DELETE /cache/clear` — clear all cache (admin)

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LeaderboardRoute"
    participant LBS as "<<service>> LeaderboardService"
    participant CACHE as "<<cache>> LeaderboardCache"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    Note over C,LOG: GET /global — Global Leaderboard
    C->>R: 1. getGlobalLeaderboard(cursor?, limit?)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>R: 1.2. parsePagination(query)
    R->>LBS: 1.3. getGlobal(pagination)
    LBS->>CACHE: 1.3.1. get(cacheKey)
    alt cache hit
        CACHE-->>LBS: PaginatedData
        LBS->>LOG: 1.3.2. log(cache:hit)
        LBS-->>R: PaginatedData
    else cache miss
        CACHE-->>LBS: null
        LBS->>LOG: 1.3.2. log(cache:miss)
        LBS->>DB: 1.3.3. query(GlobalLeaderboardRow[])
        DB-->>LBS: GlobalLeaderboardRow[]
        LBS->>CACHE: 1.3.4. set(cacheKey, data)
        LBS-->>R: PaginatedData
    end
    R-->>C: 200 PaginatedData<GlobalLeaderboardRow>

    Note over C,LOG: GET /levels/:id — Level Leaderboard
    C->>R: 2. getLevelLeaderboard(levelId, cursor?, limit?, period?)
    R->>R: 2.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>R: 2.2. parsePagination(query)
    R->>R: 2.3. parsePeriod(query)
    R->>LBS: 2.4. getByLevel(levelId, pagination, period)
    LBS->>CACHE: 2.4.1. get(cacheKey)
    alt cache hit
        CACHE-->>LBS: PaginatedData
        LBS->>LOG: 2.4.2. log(cache:hit)
        LBS-->>R: PaginatedData
    else cache miss
        CACHE-->>LBS: null
        LBS->>LOG: 2.4.2. log(cache:miss)
        LBS->>LBS: 2.4.3. periodToStartDate(period)
        LBS->>DB: 2.4.4. query(LevelLeaderboardRow[])
        DB-->>LBS: LevelLeaderboardRow[]
        LBS->>CACHE: 2.4.5. set(cacheKey, data)
        LBS-->>R: PaginatedData
    end
    R-->>C: 200 PaginatedData<LevelLeaderboardRow>

    Note over C,LOG: GET /classrooms/:id — Classroom Leaderboard
    C->>R: 3. getClassroomLeaderboard(classroomId, cursor?, limit?, period?)
    R->>R: 3.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>R: 3.2. parsePagination(query)
    R->>R: 3.3. parsePeriod(query)
    R->>LBS: 3.4. getByClassroom(classroomId, pagination, period)
    LBS->>CACHE: 3.4.1. get(cacheKey)
    alt cache hit
        CACHE-->>LBS: PaginatedData
        LBS->>LOG: 3.4.2. log(cache:hit)
        LBS-->>R: PaginatedData
    else cache miss
        CACHE-->>LBS: null
        LBS->>LOG: 3.4.2. log(cache:miss)
        LBS->>LBS: 3.4.3. periodToStartDate(period)
        LBS->>DB: 3.4.4. query(ClassroomLeaderboardRow[])
        DB-->>LBS: ClassroomLeaderboardRow[]
        LBS->>CACHE: 3.4.5. set(cacheKey, data)
        LBS-->>R: PaginatedData
    end
    R-->>C: 200 PaginatedData<ClassroomLeaderboardRow>

    Note over C,LOG: DELETE /cache/clear — Clear Cache (Admin)
    C->>R: 4. clearCache()
    R->>R: 4.1. authenticate()
    R->>R: 4.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>LBS: 4.3. invalidateAll()
    LBS->>CACHE: 4.3.1. clear()
    LBS->>LOG: 4.3.2. log(cache:pruned)
    R->>CACHE: 4.4. serialize()
    CACHE-->>R: CacheSnapshot
    R-->>C: 200 CacheSnapshot
```

## Cache Key Structure

| Scope | Key Components |
|---|---|
| Global | `table=leaderboard, scope=global, cursor, limit` |
| Level | `table=leaderboard, scope=level, levelId, period, cursor, limit` |
| Classroom | `table=leaderboard, scope=classroom, classroomId, period, cursor, limit` |

## Cache Invalidation Triggers

| Event | Invalidates |
|---|---|
| Session completed | Global + Level (by levelId) |
| Session failed | Global + Level (by levelId) |
| Admin ELO adjust | Global |
| Admin cache clear | All |
