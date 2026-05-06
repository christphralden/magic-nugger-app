# Players Route — Flowchart

## Endpoints
- `GET /:id` — get any player profile
- `PATCH /` — update own profile
- `PATCH /:id` — update any player profile (admin only)

---

## GET /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| SVC[playerService.getById playerId]
    SVC --> DB[query Player]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 ResponsePlayer]
```

## PATCH /

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([PATCH /]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize player:update}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestUpdatePlayerSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| SVC[playerService.update user.id + body]
    SVC --> DB[query Player]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 ResponsePlayer]
```

## PATCH /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([PATCH /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize admin:full}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestUpdatePlayerSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| SVC[playerService.update playerId + body]
    SVC --> DB[query Player]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 ResponsePlayer]
```
