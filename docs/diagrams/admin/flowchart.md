# Admin Route — Flowchart

All endpoints require: `authenticate` + `authorize("admin:full")`

## Endpoints
- `GET /players`
- `PATCH /players/:id/role`
- `PATCH /players/:id/elo`
- `GET /game-sessions/active`
- `GET /game-sessions`
- `GET /stats`

```mermaid
flowchart TD
    REQ([Client Request]) --> AUTH{authenticate}
    AUTH -->|not logged in| E401[401 Unauthorized]
    AUTH -->|ok| AUTHZ{authorize admin:full}
    AUTHZ -->|forbidden| E403[403 Forbidden]
    AUTHZ -->|ok| EP{Which endpoint?}

    %% --- GET /players ---
    EP -->|GET /players| GP[parsePagination cursor + limit]
    GP --> GP_Q["SELECT players WHERE created_at < cursor ORDER BY created_at DESC LIMIT n"]
    GP_Q --> GP_LOG[log admin:player_viewed]
    GP_LOG --> GP200["200 PaginatedData<Player>"]

    %% --- PATCH /players/:id/role ---
    EP -->|PATCH /players/:id/role| PR_V[validate {role: string}]
    PR_V -->|invalid| E400[400 Bad Request]
    PR_V -->|valid| PR_Q["UPDATE players SET role_id = (SELECT id FROM roles WHERE name=$role)"]
    PR_Q -->|no rows| PR_404[404 Not Found]
    PR_Q -->|updated| PR_LOG[log admin:role_changed]
    PR_LOG --> PR200[200 OK]

    %% --- PATCH /players/:id/elo ---
    EP -->|PATCH /players/:id/elo| PE_V[validate RequestAdjustEloSchema]
    PE_V -->|invalid| E400
    PE_V -->|valid| PE_GET["SELECT current_elo FROM players WHERE id=$id"]
    PE_GET -->|not found| PE_404[404 Not Found]
    PE_GET -->|found| PE_TX["tx: UPDATE players.current_elo + INSERT elo_history reason=admin_adjustment"]
    PE_TX --> PE_CACHE[leaderboardService.invalidateGlobal]
    PE_CACHE --> PE_LOG["log admin:elo_adjusted + elo:admin_adjusted"]
    PE_LOG --> PE200[200 OK]

    %% --- GET /game-sessions/active ---
    EP -->|GET /game-sessions/active| GA_Q["SELECT * FROM game_sessions WHERE status='in_progress' ORDER BY started_at DESC LIMIT 100"]
    GA_Q --> GA_LOG[log admin:sessions_viewed filter=active]
    GA_LOG --> GA200["200 GameSession[]"]

    %% --- GET /game-sessions ---
    EP -->|GET /game-sessions| GS_P[parsePagination]
    GS_P --> GS_W["Build WHERE: player_id? level_id? status? cursor?"]
    GS_W --> GS_Q[SELECT game_sessions with dynamic filters]
    GS_Q --> GS_LOG[log admin:sessions_viewed]
    GS_LOG --> GS200["200 PaginatedData<GameSession>"]

    %% --- GET /stats ---
    EP -->|GET /stats| ST_Q["SELECT COUNT total_players, total_sessions, completed_sessions"]
    ST_Q --> ST200[200 stats object]
```
