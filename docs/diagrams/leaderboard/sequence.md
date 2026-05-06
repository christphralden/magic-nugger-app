# Leaderboard Route — Sequence Diagrams

All endpoints require `authenticate`. Cache clear requires `authorize("admin:full")`.

## Endpoints
- `GET /global` — global leaderboard
- `GET /levels/:id` — level leaderboard
- `GET /classrooms/:id` — classroom leaderboard
- `DELETE /cache/clear` — clear all cache (admin)

```mermaid
sequenceDiagram
    participant C as Client
    participant R as LeaderboardRouter
    participant MW as Middleware
    participant LBS as LeaderboardService
    participant CACHE as LeaderboardCache
    participant DB as Database
    participant L as LoggingService

    rect rgb(240, 248, 255)
        Note over C,L: GET /global — Global Leaderboard
        C->>R: GET /global?cursor=&limit=
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>R: parsePagination(query)
        R->>LBS: getGlobal(pagination)
        LBS->>CACHE: get(cacheKey)
        alt Cache hit
            CACHE-->>LBS: cached data
            LBS->>L: log(cache:hit)
            LBS-->>R: PaginatedData
        else Cache miss
            CACHE-->>LBS: null
            LBS->>L: log(cache:miss)
            LBS->>DB: SELECT players + LEFT JOIN game_sessions(completed) WHERE current_elo < cursor GROUP BY player ORDER BY current_elo DESC LIMIT n
            DB-->>LBS: GlobalLeaderboardRow[]
            LBS->>CACHE: set(cacheKey, data)
            LBS-->>R: PaginatedData
        end
        R-->>C: 200 PaginatedData<GlobalLeaderboardRow>
    end

    rect rgb(240, 255, 240)
        Note over C,L: GET /levels/:id — Level Leaderboard
        C->>R: GET /levels/:id?cursor=&limit=&period=
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>R: parsePagination(query) + parsePeriod(query)
        R->>LBS: getByLevel(levelId, pagination, period)
        LBS->>CACHE: get(cacheKey with levelId+period)
        alt Cache hit
            CACHE-->>LBS: cached data
            LBS->>L: log(cache:hit)
            LBS-->>R: PaginatedData
        else Cache miss
            CACHE-->>LBS: null
            LBS->>L: log(cache:miss)
            LBS->>LBS: periodToStartDate(period)
            LBS->>DB: SELECT player_id, MAX(score) best_score, MAX(max_streak) FROM game_sessions JOIN players WHERE level_id=$1 AND status=completed AND ended_at >= start_date GROUP BY player HAVING best_score < cursor ORDER BY best_score DESC LIMIT n
            DB-->>LBS: LevelLeaderboardRow[]
            LBS->>CACHE: set(cacheKey, data)
            LBS-->>R: PaginatedData
        end
        R-->>C: 200 PaginatedData<LevelLeaderboardRow>
    end

    rect rgb(255, 250, 240)
        Note over C,L: GET /classrooms/:id — Classroom Leaderboard
        C->>R: GET /classrooms/:id?cursor=&limit=&period=
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>R: parsePagination(query) + parsePeriod(query)
        R->>LBS: getByClassroom(classroomId, pagination, period)
        LBS->>CACHE: get(cacheKey with classroomId+period)
        alt Cache hit
            CACHE-->>LBS: cached data
            LBS->>L: log(cache:hit)
            LBS-->>R: PaginatedData
        else Cache miss
            CACHE-->>LBS: null
            LBS->>L: log(cache:miss)
            LBS->>LBS: periodToStartDate(period)
            LBS->>DB: SELECT cm.player_id, username, display_name, classroom_elo, MAX(gs.max_streak) FROM classroom_members cm JOIN players JOIN game_sessions(completed, period) WHERE cm.classroom_id=$1 AND classroom_elo < cursor GROUP BY player ORDER BY classroom_elo DESC LIMIT n
            DB-->>LBS: ClassroomLeaderboardRow[]
            LBS->>CACHE: set(cacheKey, data)
            LBS-->>R: PaginatedData
        end
        R-->>C: 200 PaginatedData<ClassroomLeaderboardRow>
    end

    rect rgb(255, 240, 255)
        Note over C,L: DELETE /cache/clear — Clear Cache (Admin)
        C->>R: DELETE /cache/clear
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>LBS: invalidateAll()
        LBS->>CACHE: clear all entries
        LBS->>L: log(cache:pruned)
        R->>CACHE: serialize()
        CACHE-->>R: cache state snapshot
        R-->>C: 200 cache state
    end
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
