# Players Route — Sequence Diagrams

All endpoints require `authenticate`.

## Endpoints
- `GET /:id` — get any player profile
- `PATCH /` — update own profile
- `PATCH /:id` — update any player profile (admin only)

```mermaid
sequenceDiagram
    participant C as Client
    participant R as PlayersRouter
    participant MW as Middleware
    participant PS as PlayerService
    participant DB as Database

    rect rgb(240, 248, 255)
        Note over C,DB: GET /:id — Get Player Profile
        C->>R: GET /:id
        R->>MW: authenticate
        MW-->>C: 401 Unauthorized (if not logged in)
        R->>PS: getById(params.id)
        PS->>DB: SELECT id, username, display_name, current_elo, highest_level_unlocked, avatar_url FROM players WHERE id=$1
        DB-->>PS: Player row or null
        PS-->>R: 404 AppError (if null)
        PS-->>R: ResponsePlayer
        R-->>C: 200 ResponsePlayer
    end

    rect rgb(240, 255, 240)
        Note over C,DB: PATCH / — Update Own Profile
        C->>R: PATCH / {display_name?, username?, avatar_url?}
        R->>MW: authenticate + authorize(player:update)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestUpdatePlayerSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>PS: update(user.id, body)
        PS->>DB: UPDATE players SET COALESCE(display_name, username, avatar_url), updated_at=now() WHERE id=$1
        DB-->>PS: Updated player row or null
        PS-->>R: 404 AppError (if null)
        PS-->>R: ResponsePlayer
        R-->>C: 200 ResponsePlayer
    end

    rect rgb(255, 250, 240)
        Note over C,DB: PATCH /:id — Admin Update Any Player
        C->>R: PATCH /:id {display_name?, username?, avatar_url?}
        R->>MW: authenticate + authorize(admin:full)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestUpdatePlayerSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>PS: update(params.id, body)
        PS->>DB: UPDATE players SET COALESCE(display_name, username, avatar_url), updated_at=now() WHERE id=$1
        DB-->>PS: Updated player row or null
        PS-->>R: 404 AppError (if null)
        PS-->>R: ResponsePlayer
        R-->>C: 200 ResponsePlayer
    end
```

## Notes

- `updateAfterSession` in `PlayerService` is **not** called from this route — it is called internally by `GameService.end()` after a game session completes or fails.
- Both `PATCH /` and `PATCH /:id` share the same `PlayerService.update()` method; the difference is which player ID is passed (`user.id` vs `params.id`).
