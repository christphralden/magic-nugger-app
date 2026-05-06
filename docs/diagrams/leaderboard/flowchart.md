# Leaderboard Route — Flowchart

All endpoints require `authenticate`. Cache clear requires `authorize("admin:full")`.

## Endpoints
- `GET /global` — global leaderboard
- `GET /levels/:id` — level leaderboard
- `GET /classrooms/:id` — classroom leaderboard
- `DELETE /cache/clear` — clear all cache (admin)

```mermaid
flowchart TD
    REQ([Client Request]) --> AUTH{authenticate}
    AUTH -->|not logged in| E401[401 Unauthorized]
    AUTH -->|ok| EP{Which endpoint?}

    %% --- GET /global ---
    EP -->|GET /global| GL_P[parsePagination cursor + limit]
    GL_P --> GL_SVC[leaderboardService.getGlobal pagination]
    GL_SVC --> GL_CACHE{Cache hit?}
    GL_CACHE -->|hit| GL_LOG_HIT[log cache:hit]
    GL_LOG_HIT --> GL200["200 PaginatedData<GlobalLeaderboardRow>"]

    GL_CACHE -->|miss| GL_LOG_MISS[log cache:miss]
    GL_LOG_MISS --> GL_Q["SELECT p.id, username, display_name, avatar_url, current_elo, MAX(gs.max_streak)\nFROM players p LEFT JOIN game_sessions gs ON status=completed\nWHERE current_elo < cursor\nGROUP BY player ORDER BY current_elo DESC LIMIT n"]
    GL_Q --> GL_SET[set cache]
    GL_SET --> GL200

    %% --- GET /levels/:id ---
    EP -->|GET /levels/:id| LV_P[parsePagination + parsePeriod]
    LV_P --> LV_SVC[leaderboardService.getByLevel levelId + pagination + period]
    LV_SVC --> LV_CACHE{Cache hit?}
    LV_CACHE -->|hit| LV_LOG_HIT[log cache:hit]
    LV_LOG_HIT --> LV200["200 PaginatedData<LevelLeaderboardRow>"]

    LV_CACHE -->|miss| LV_LOG_MISS[log cache:miss]
    LV_LOG_MISS --> LV_DATE[periodToStartDate period]
    LV_DATE --> LV_Q["SELECT gs.player_id, username, display_name, MAX(gs.score) best_score, MAX(gs.max_streak)\nFROM game_sessions gs JOIN players p\nWHERE level_id=$1 AND status=completed AND ended_at >= start_date\nGROUP BY player HAVING best_score < cursor ORDER BY best_score DESC LIMIT n"]
    LV_Q --> LV_SET[set cache]
    LV_SET --> LV200

    %% --- GET /classrooms/:id ---
    EP -->|GET /classrooms/:id| CR_P[parsePagination + parsePeriod]
    CR_P --> CR_SVC[leaderboardService.getByClassroom classroomId + pagination + period]
    CR_SVC --> CR_CACHE{Cache hit?}
    CR_CACHE -->|hit| CR_LOG_HIT[log cache:hit]
    CR_LOG_HIT --> CR200["200 PaginatedData<ClassroomLeaderboardRow>"]

    CR_CACHE -->|miss| CR_LOG_MISS[log cache:miss]
    CR_LOG_MISS --> CR_DATE[periodToStartDate period]
    CR_DATE --> CR_Q["SELECT cm.player_id, username, display_name, cm.classroom_elo, MAX(gs.max_streak)\nFROM classroom_members cm JOIN players p JOIN game_sessions gs\nWHERE cm.classroom_id=$1 AND classroom_elo < cursor\nGROUP BY player ORDER BY classroom_elo DESC LIMIT n"]
    CR_Q --> CR_SET[set cache]
    CR_SET --> CR200

    %% --- DELETE /cache/clear (admin) ---
    EP -->|DELETE /cache/clear| CC_AZ{authorize admin:full}
    CC_AZ -->|forbidden| E403[403 Forbidden]
    CC_AZ -->|ok| CC_SVC[leaderboardService.invalidateAll]
    CC_SVC --> CC_SERIAL[leaderboardCache.serialize]
    CC_SERIAL --> CC200[200 cache state]
```
