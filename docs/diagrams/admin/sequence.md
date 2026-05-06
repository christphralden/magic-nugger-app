# Admin Route — Sequence Diagrams

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
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AdminRoute"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

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
    R-->>C: 200 PaginatedData(Player)
```

## PATCH /players/:id/role

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AdminRoute"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    C->>R: 1. setPlayerRole(playerId, role)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(role)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>DB: 1.4. query(Player)
    DB-->>R: Player?
    alt not found
        R-->>C: 404 NotFound
    end
    R->>LOG: 1.5. log(admin:role_changed)
    R-->>C: 200 null
```

## PATCH /players/:id/elo

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AdminRoute"
    participant LBS as "<<service>> LeaderboardService"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    C->>R: 1. adjustPlayerElo(playerId, elo, reason)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestAdjustEloSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>DB: 1.4. query(Player)
    DB-->>R: {current_elo}?
    alt not found
        R-->>C: 404 NotFound
    end
    R->>DB: 1.5. tx: query(Player, EloHistory)
    DB-->>R: ok
    R->>LBS: 1.6. invalidateGlobal()
    R->>LOG: 1.7. log(admin:elo_adjusted)
    R->>LOG: 1.8. log(elo:admin_adjusted)
    R-->>C: 200 null
```

## GET /game-sessions/active

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AdminRoute"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    C->>R: 1. getActiveSessions()
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>DB: 1.3. query(GameSession[])
    DB-->>R: GameSession[]
    R->>LOG: 1.4. log(admin:sessions_viewed)
    R-->>C: 200 GameSession[]
```

## GET /game-sessions

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AdminRoute"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    C->>R: 1. listSessions(player_id?, level_id?, status?, cursor?, limit?)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. parsePagination(query)
    R->>DB: 1.4. query(GameSession[])
    DB-->>R: GameSession[]
    R->>LOG: 1.5. log(admin:sessions_viewed)
    R-->>C: 200 PaginatedData(GameSession)
```

## GET /stats

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AdminRoute"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. getStats()
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>DB: 1.3. query(Stats)
    DB-->>R: Stats
    R-->>C: 200 Stats
```
