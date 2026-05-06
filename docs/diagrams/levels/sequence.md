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
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    Note over C,DB: GET / — All Active Levels
    C->>R: 1. getLevels()
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>LS: 1.2. getAll()
    LS->>DB: 1.2.1. query(Level[])
    DB-->>LS: Level[]
    LS-->>R: Level[]
    R-->>C: 200 Level[] / 204 NoContent

    Note over C,DB: GET /:id — Single Level
    C->>R: 2. getLevel(levelId)
    R->>R: 2.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>LS: 2.2. getById(levelId)
    LS->>DB: 2.2.1. query(Level)
    DB-->>LS: Level?
    alt not found
        LS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    LS-->>R: Level
    R-->>C: 200 Level

    Note over C,DB: POST / — Create Level
    C->>R: 3. createLevel(name, order_index, elo_min, elo_gain_correct, elo_loss_incorrect, configs, max_score)
    R->>R: 3.1. authenticate()
    R->>R: 3.2. authorize(level:create)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 3.3. validate(RequestCreateLevelSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>LS: 3.4. create(body)
    LS->>DB: 3.4.1. query(Level)
    DB-->>LS: Level
    LS-->>R: Level
    R-->>C: 201 Level

    Note over C,DB: PUT /:id — Update Level
    C->>R: 4. updateLevel(levelId, fields?)
    R->>R: 4.1. authenticate()
    R->>R: 4.2. authorize(level:update)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 4.3. validate(RequestUpdateLevelSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>LS: 4.4. update(levelId, body)
    LS->>DB: 4.4.1. query(Level)
    DB-->>LS: Level?
    alt not found
        LS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    LS-->>R: Level
    R-->>C: 200 Level

    Note over C,DB: PUT /active/:id — Activate or Deactivate Level
    C->>R: 5. setLevelActive(levelId, is_active)
    R->>R: 5.1. authenticate()
    R->>R: 5.2. authorize(level:activate)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 5.3. validate(RequestUpdateActiveLevelSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>LS: 5.4. activate(levelId, is_active)
    LS->>DB: 5.4.1. query(Level)
    DB-->>LS: Level?
    alt not found
        LS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    LS-->>R: Level
    R-->>C: 200 Level

    Note over C,DB: DELETE /:id — Soft Delete Level
    C->>R: 6. deleteLevel(levelId)
    R->>R: 6.1. authenticate()
    R->>R: 6.2. authorize(level:delete)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>LS: 6.3. delete(levelId)
    LS->>DB: 6.3.1. query(Level)
    DB-->>LS: ok
    R-->>C: 204 NoContent
```

## Notes

- `getNextActive({afterId})` in `LevelService` is **not** called from this route — it is called internally by `GameService.end()` to determine the next unlockable level after session completion.
- Level ordering is by `order_index`, not by `id`. Progression follows `order_index ASC`.
