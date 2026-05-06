# Levels Route — Flowchart

All endpoints require `authenticate`. Some require `authorize(permission)`.

## Endpoints
- `GET /` — get all active levels
- `GET /:id` — get specific level
- `POST /` — create level
- `PUT /:id` — update level
- `PUT /active/:id` — activate or deactivate level
- `DELETE /:id` — soft delete level

```mermaid
flowchart TD
    REQ([Client Request]) --> AUTH{authenticate}
    AUTH -->|not logged in| E401[401 Unauthorized]
    AUTH -->|ok| EP{Which endpoint?}

    %% --- GET / (all) ---
    EP -->|GET /| GA_SVC[levelService.getAll]
    GA_SVC --> GA_Q["SELECT * FROM levels WHERE is_active=true ORDER BY order_index"]
    GA_Q -->|empty| GA204[204 No Content]
    GA_Q -->|results| GA200["200 Level[]"]

    %% --- GET /:id ---
    EP -->|GET /:id| GI_SVC[levelService.getById id]
    GI_SVC --> GI_Q["SELECT * FROM levels WHERE id=$1 AND is_active=true"]
    GI_Q -->|not found| GI_404[404 Not Found]
    GI_Q -->|found| GI200[200 Level]

    %% --- POST / (create) ---
    EP -->|POST /| C_AZ{authorize level:create}
    C_AZ -->|forbidden| E403[403 Forbidden]
    C_AZ -->|ok| C_V[validate RequestCreateLevelSchema]
    C_V -->|invalid| E400[400 Bad Request]
    C_V -->|valid| C_SVC[levelService.create body]
    C_SVC --> C_Q["INSERT INTO levels enemy_wave_config+question_gen_config as JSON"]
    C_Q --> C201[201 Level]

    %% --- PUT /:id (update) ---
    EP -->|PUT /:id| U_AZ{authorize level:update}
    U_AZ -->|forbidden| E403
    U_AZ -->|ok| U_V[validate RequestUpdateLevelSchema]
    U_V -->|invalid| E400
    U_V -->|valid| U_SVC[levelService.update id + body]
    U_SVC --> U_Q["UPDATE levels SET COALESCE fields, updated_at=now() WHERE id=$1"]
    U_Q -->|not found| U_404[404 Not Found]
    U_Q -->|updated| U200[200 Level]

    %% --- PUT /active/:id (activate) ---
    EP -->|PUT /active/:id| A_AZ{authorize level:activate}
    A_AZ -->|forbidden| E403
    A_AZ -->|ok| A_V[validate RequestUpdateActiveLevelSchema]
    A_V -->|invalid| E400
    A_V -->|valid| A_SVC[levelService.activate id + is_active]
    A_SVC --> A_Q["UPDATE levels SET is_active=$2, updated_at=now() WHERE id=$1"]
    A_Q -->|not found| A_404[404 Not Found]
    A_Q -->|updated| A200[200 Level]

    %% --- DELETE /:id (soft delete) ---
    EP -->|DELETE /:id| D_AZ{authorize level:delete}
    D_AZ -->|forbidden| E403
    D_AZ -->|ok| D_SVC[levelService.delete id]
    D_SVC --> D_Q["UPDATE levels SET is_active=false, updated_at=now() WHERE id=$1"]
    D_Q --> D204[204 No Content]
```
