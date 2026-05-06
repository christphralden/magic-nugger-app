# Admin Route — Sequence Diagrams

All endpoints require: `authenticate` + `authorize("admin:full")`

## Endpoints
- `GET /players`
- `PATCH /players/:id/role`
- `PATCH /players/:id/elo`
- `GET /game-sessions/active`
- `GET /game-sessions`
- `GET /stats`

```mermaid
sequenceDiagram
    participant C as Client
    participant R as AdminRouter
    participant MW as Middleware
    participant DB as Database
    participant LS as LeaderboardService
    participant L as LoggingService

    rect rgb(240, 248, 255)
        Note over C,L: GET /players
        C->>R: GET /players?cursor=&limit=
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>R: parsePagination(query)
        R->>DB: SELECT players WHERE created_at < cursor ORDER BY created_at DESC LIMIT n
        DB-->>R: Player[]
        R->>L: log(admin:player_viewed, userId)
        R-->>C: 200 PaginatedData<Player>
    end

    rect rgb(240, 255, 240)
        Note over C,L: PATCH /players/:id/role
        C->>R: PATCH /players/:id/role {role}
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate({role: string})
        MW-->>C: 400 Bad Request (if invalid)
        R->>DB: UPDATE players SET role_id = (SELECT id FROM roles WHERE name=$role)
        DB-->>R: {id} or 0 rows
        R-->>C: 404 Not Found (if 0 rows)
        R->>L: log(admin:role_changed, {target_player_id, new_role})
        R-->>C: 200 OK
    end

    rect rgb(255, 250, 240)
        Note over C,L: PATCH /players/:id/elo
        C->>R: PATCH /players/:id/elo {elo, reason}
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestAdjustEloSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>DB: SELECT current_elo FROM players WHERE id=$id
        DB-->>R: {current_elo} or null
        R-->>C: 404 Not Found (if null)
        R->>DB: tx: UPDATE players.current_elo + INSERT elo_history(reason=admin_adjustment)
        DB-->>R: ok
        R->>LS: invalidateGlobal()
        R->>L: log(admin:elo_adjusted) + log(elo:admin_adjusted)
        R-->>C: 200 OK
    end

    rect rgb(255, 240, 255)
        Note over C,L: GET /game-sessions/active
        C->>R: GET /game-sessions/active
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>DB: SELECT * FROM game_sessions WHERE status='in_progress' ORDER BY started_at DESC LIMIT 100
        DB-->>R: GameSession[]
        R->>L: log(admin:sessions_viewed, {filter: active})
        R-->>C: 200 GameSession[]
    end

    rect rgb(240, 255, 255)
        Note over C,L: GET /game-sessions
        C->>R: GET /game-sessions?player_id=&level_id=&status=&cursor=&limit=
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>R: parsePagination + build dynamic WHERE conditions
        R->>DB: SELECT game_sessions with filters ORDER BY started_at DESC LIMIT n
        DB-->>R: GameSession[]
        R->>L: log(admin:sessions_viewed, filter)
        R-->>C: 200 PaginatedData<GameSession>
    end

    rect rgb(255, 255, 240)
        Note over C,L: GET /stats
        C->>R: GET /stats
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>DB: SELECT COUNT total_players, total_sessions, completed_sessions
        DB-->>R: stats row
        R-->>C: 200 {total_players, total_sessions, completed_sessions}
    end
```
