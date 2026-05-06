# Levels Route — Sequence Diagrams

All endpoints require `authenticate`. Some require `authorize(permission)`.

## Endpoints
- `GET /` — get all active levels
- `GET /:id` — get specific level
- `POST /` — create level
- `PUT /:id` — update level
- `PUT /active/:id` — activate or deactivate level
- `DELETE /:id` — soft delete level

```mermaid
sequenceDiagram
    participant C as Client
    participant R as LevelsRouter
    participant MW as Middleware
    participant LS as LevelService
    participant DB as Database

    rect rgb(240, 248, 255)
        Note over C,DB: GET / — All Active Levels
        C->>R: GET /
        R->>MW: authenticate
        MW-->>C: 401 Unauthorized (if not logged in)
        R->>LS: getAll()
        LS->>DB: SELECT * FROM levels WHERE is_active=true ORDER BY order_index
        DB-->>LS: Level[] (validated per row with LevelSchema)
        LS-->>R: Level[]
        R-->>C: 200 Level[] or 204 No Content
    end

    rect rgb(240, 255, 240)
        Note over C,DB: GET /:id — Single Level
        C->>R: GET /:id
        R->>MW: authenticate
        MW-->>C: 401 Unauthorized (if not logged in)
        R->>LS: getById(id)
        LS->>DB: SELECT * FROM levels WHERE id=$1 AND is_active=true
        DB-->>LS: Level or null
        LS-->>R: 404 AppError (if null)
        LS-->>R: Level
        R-->>C: 200 Level
    end

    rect rgb(255, 250, 240)
        Note over C,DB: POST / — Create Level
        C->>R: POST / {name, order_index, elo_min, elo_gain_correct, elo_loss_incorrect, enemy_wave_config, question_gen_config, max_score, ...}
        R->>MW: authenticate + authorize(level:create)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestCreateLevelSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>LS: create(body)
        LS->>DB: INSERT INTO levels (JSON configs serialized)
        DB-->>LS: Level row
        LS-->>R: Level
        R-->>C: 201 Level
    end

    rect rgb(255, 240, 255)
        Note over C,DB: PUT /:id — Update Level
        C->>R: PUT /:id {name?, elo_min?, elo_gain_correct?, ...}
        R->>MW: authenticate + authorize(level:update)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestUpdateLevelSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>LS: update(id, body)
        LS->>DB: UPDATE levels SET COALESCE(fields), updated_at=now() WHERE id=$1
        DB-->>LS: Updated Level or null
        LS-->>R: 404 AppError (if null)
        LS-->>R: Level
        R-->>C: 200 Level
    end

    rect rgb(240, 255, 255)
        Note over C,DB: PUT /active/:id — Activate or Deactivate Level
        C->>R: PUT /active/:id {is_active}
        R->>MW: authenticate + authorize(level:activate)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestUpdateActiveLevelSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>LS: activate(id, {is_active})
        LS->>DB: UPDATE levels SET is_active=$2, updated_at=now() WHERE id=$1
        DB-->>LS: Updated Level or null
        LS-->>R: 404 AppError (if null)
        LS-->>R: Level
        R-->>C: 200 Level
    end

    rect rgb(255, 255, 240)
        Note over C,DB: DELETE /:id — Soft Delete Level
        C->>R: DELETE /:id
        R->>MW: authenticate + authorize(level:delete)
        MW-->>C: 401/403 (if unauthorized)
        R->>LS: delete(id)
        LS->>DB: UPDATE levels SET is_active=false, updated_at=now() WHERE id=$1
        DB-->>LS: ok
        LS-->>R: void
        R-->>C: 204 No Content
    end
```

## Notes

- `getNextActive({afterId})` in `LevelService` is **not** called from this route — it is called internally by `GameService.end()` to determine the next unlockable level after session completion.
- Level ordering is by `order_index`, not by `id`. Progression follows `order_index ASC`.
