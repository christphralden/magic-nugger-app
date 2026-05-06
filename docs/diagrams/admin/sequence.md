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
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AdminRoute"
    participant LBS as "<<service>> LeaderboardService"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    Note over C,LOG: GET /players
    C->>R: 1. listPlayers(cursor?, limit?)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. parsePagination(query)
    R->>DB: 1.4. query(Player[])
    DB-->>R: Player[]
    R->>LOG: 1.5. log(admin:player_viewed)
    R-->>C: 200 PaginatedData<Player>

    Note over C,LOG: PATCH /players/:id/role
    C->>R: 2. setPlayerRole(playerId, role)
    R->>R: 2.1. authenticate()
    R->>R: 2.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 2.3. validate(role)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>DB: 2.4. query(Player)
    DB-->>R: Player?
    alt not found
        R-->>C: 404 NotFound
    end
    R->>LOG: 2.5. log(admin:role_changed)
    R-->>C: 200 null

    Note over C,LOG: PATCH /players/:id/elo
    C->>R: 3. adjustPlayerElo(playerId, elo, reason)
    R->>R: 3.1. authenticate()
    R->>R: 3.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 3.3. validate(RequestAdjustEloSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>DB: 3.4. query(Player)
    DB-->>R: {current_elo}?
    alt not found
        R-->>C: 404 NotFound
    end
    R->>DB: 3.5. tx: query(Player, EloHistory)
    DB-->>R: ok
    R->>LBS: 3.6. invalidateGlobal()
    R->>LOG: 3.7. log(admin:elo_adjusted)
    R->>LOG: 3.8. log(elo:admin_adjusted)
    R-->>C: 200 null

    Note over C,LOG: GET /game-sessions/active
    C->>R: 4. getActiveSessions()
    R->>R: 4.1. authenticate()
    R->>R: 4.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>DB: 4.3. query(GameSession[])
    DB-->>R: GameSession[]
    R->>LOG: 4.4. log(admin:sessions_viewed)
    R-->>C: 200 GameSession[]

    Note over C,LOG: GET /game-sessions
    C->>R: 5. listSessions(player_id?, level_id?, status?, cursor?, limit?)
    R->>R: 5.1. authenticate()
    R->>R: 5.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 5.3. parsePagination(query)
    R->>DB: 5.4. query(GameSession[])
    DB-->>R: GameSession[]
    R->>LOG: 5.5. log(admin:sessions_viewed)
    R-->>C: 200 PaginatedData<GameSession>

    Note over C,LOG: GET /stats
    C->>R: 6. getStats()
    R->>R: 6.1. authenticate()
    R->>R: 6.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>DB: 6.3. query(Stats)
    DB-->>R: Stats
    R-->>C: 200 Stats
```
