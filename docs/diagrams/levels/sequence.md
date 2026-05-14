# Levels Route — Sequence Diagrams

## Endpoints
- `GET /` — get all active levels
- `GET /:id` — get specific level
- `POST /` — create level
- `PUT /:id` — update level
- `PUT /active/:id` — activate or deactivate level
- `DELETE /:id` — soft delete level
- `GET /unlocked` — get unlocked levels for player

---

## GET /

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

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
```

## GET /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. getLevel(levelId)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>LS: 1.2. getById(levelId)
    LS->>DB: 1.2.1. query(Level)
    DB-->>LS: Level?
    alt not found
        LS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    LS-->>R: Level
    R-->>C: 200 Level
```

## POST /

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. createLevel(name, order_index, child_levels?, elo_min, elo_gain_correct, elo_loss_incorrect, configs)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(level:create)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestCreateLevelSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>LS: 1.4. create(body)
    LS->>DB: 1.4.1. query(Level)
    DB-->>LS: Level
    LS-->>R: Level
    R-->>C: 201 Level
```

## PUT /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. updateLevel(levelId, fields?)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(level:update)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestUpdateLevelSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>LS: 1.4. update(levelId, body)
    LS->>DB: 1.4.1. query(Level)
    DB-->>LS: Level?
    alt not found
        LS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    LS-->>R: Level
    R-->>C: 200 Level
```

## PUT /active/:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. setLevelActive(levelId, is_active)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(level:activate)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestUpdateActiveLevelSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>LS: 1.4. activate(levelId, is_active)
    LS->>DB: 1.4.1. query(Level)
    DB-->>LS: Level?
    alt not found
        LS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    LS-->>R: Level
    R-->>C: 200 Level
```

## DELETE /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. deleteLevel(levelId)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(level:delete)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>LS: 1.3. delete(levelId)
    LS->>DB: 1.3.1. query(Level)
    DB-->>LS: ok
    R-->>C: 204 NoContent
```

## GET /unlocked

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> LevelsRoute"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. getUnlockedLevels()
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>LS: 1.2. getUnlockedByPlayer(userId)
    LS->>DB: 1.2.1. query(LevelsUnlocked)
    DB-->>LS: string[]
    LS-->>R: string[]
    R-->>C: 200 string[]
```

## Notes

- `getNextActive({afterId})` in `LevelService` is **not** called from this route — it is called internally by `GameService.end()` to determine the next unlockable level after session completion.
- Level ordering is by `order_index`, not by `id`. Progression follows `order_index ASC`.
