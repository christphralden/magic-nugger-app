# Players Route — Sequence Diagrams

## Endpoints
- `GET /:id` — get any player profile
- `PATCH /` — update own profile
- `PATCH /:id` — update any player profile (admin only)

---

## GET /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> PlayersRoute"
    participant PS as "<<service>> PlayerService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. getPlayer(playerId)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>PS: 1.2. getById(playerId)
    PS->>DB: 1.2.1. query(Player)
    DB-->>PS: Player?
    alt not found
        PS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    PS-->>R: ResponsePlayer
    R-->>C: 200 ResponsePlayer
```

## PATCH /

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> PlayersRoute"
    participant PS as "<<service>> PlayerService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. updateProfile(display_name?, username?, avatar_url?)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(player:update)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestUpdatePlayerSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>PS: 1.4. update(user.id, body)
    PS->>DB: 1.4.1. query(Player)
    DB-->>PS: Player?
    alt not found
        PS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    PS-->>R: ResponsePlayer
    R-->>C: 200 ResponsePlayer
```

## PATCH /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> PlayersRoute"
    participant PS as "<<service>> PlayerService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. adminUpdatePlayer(playerId, display_name?, username?, avatar_url?)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(admin:full)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestUpdatePlayerSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>PS: 1.4. update(playerId, body)
    PS->>DB: 1.4.1. query(Player)
    DB-->>PS: Player?
    alt not found
        PS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    PS-->>R: ResponsePlayer
    R-->>C: 200 ResponsePlayer
```

## Notes

- `updateAfterSession` in `PlayerService` is **not** called from this route — it is called internally by `GameService.end()` after a game session completes or fails.
- Both `PATCH /` and `PATCH /:id` share the same `PlayerService.update()` method; the difference is which player ID is passed (`user.id` vs `params.id`).
