# Players Route — Flowchart

All endpoints require `authenticate`.

## Endpoints
- `GET /:id` — get any player profile
- `PATCH /` — update own profile
- `PATCH /:id` — update any player profile (admin only)

```mermaid
flowchart TD
    REQ([Client Request]) --> AUTH{authenticate}
    AUTH -->|not logged in| E401[401 Unauthorized]
    AUTH -->|ok| EP{Which endpoint?}

    %% --- GET /:id ---
    EP -->|GET /:id| GET_SVC[playerService.getById params.id]
    GET_SVC --> GET_Q["SELECT id, username, display_name, current_elo, highest_level_unlocked, avatar_url FROM players WHERE id=$1"]
    GET_Q -->|not found| GET_404[404 Not Found]
    GET_Q -->|found| GET200[200 ResponsePlayer]

    %% --- PATCH / (own profile) ---
    EP -->|PATCH /| OWN_AZ{authorize player:update}
    OWN_AZ -->|forbidden| E403[403 Forbidden]
    OWN_AZ -->|ok| OWN_V[validate RequestUpdatePlayerSchema]
    OWN_V -->|invalid| E400[400 Bad Request]
    OWN_V -->|valid| OWN_SVC[playerService.update user.id + body]
    OWN_SVC --> OWN_Q["UPDATE players SET COALESCE display_name, username, avatar_url WHERE id=user.id"]
    OWN_Q -->|not found| OWN_404[404 Not Found]
    OWN_Q -->|updated| OWN200[200 ResponsePlayer]

    %% --- PATCH /:id (admin) ---
    EP -->|PATCH /:id| ADM_AZ{authorize admin:full}
    ADM_AZ -->|forbidden| E403
    ADM_AZ -->|ok| ADM_V[validate RequestUpdatePlayerSchema]
    ADM_V -->|invalid| E400
    ADM_V -->|valid| ADM_SVC[playerService.update params.id + body]
    ADM_SVC --> ADM_Q["UPDATE players SET COALESCE display_name, username, avatar_url WHERE id=params.id"]
    ADM_Q -->|not found| ADM_404[404 Not Found]
    ADM_Q -->|updated| ADM200[200 ResponsePlayer]
```
