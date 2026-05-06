# Levels Route — Flowchart

## Endpoints
- `GET /` — get all active levels
- `GET /:id` — get specific level
- `POST /` — create level
- `PUT /:id` — update level
- `PUT /active/:id` — activate or deactivate level
- `DELETE /:id` — soft delete level

---

## GET /

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| SVC[levelService.getAll]
    SVC --> DB[query Level array]
    DB --> CHECK{results?}
    CHECK -->|empty| R204[204 NoContent]
    CHECK -->|found| R200[200 Level array]
```

## GET /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| SVC[levelService.getById levelId]
    SVC --> DB[query Level]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 Level]
```

## POST /

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize level:create}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestCreateLevelSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| SVC[levelService.create body]
    SVC --> DB[query Level]
    DB --> R201[201 Level]
```

## PUT /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([PUT /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize level:update}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestUpdateLevelSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| SVC[levelService.update levelId + body]
    SVC --> DB[query Level]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 Level]
```

## PUT /active/:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([PUT /active/:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize level:activate}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestUpdateActiveLevelSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| SVC[levelService.activate levelId + is_active]
    SVC --> DB[query Level]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 Level]
```

## DELETE /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([DELETE /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize level:delete}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| SVC[levelService.delete levelId]
    SVC --> DB[query Level soft delete]
    DB --> R204[204 NoContent]
```
