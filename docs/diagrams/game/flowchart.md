# Game Route — Flowchart

All endpoints require `authenticate`. No additional permission required.

## Endpoints
- `POST /` — start or resume game session
- `POST /:id/answer` — submit answer
- `POST /:id/end` — complete session (success)
- `POST /:id/fail` — fail session
- `POST /:id/abandon` — abandon session

```mermaid
flowchart TD
    REQ([Client Request]) --> AUTH{authenticate}
    AUTH -->|not logged in| E401[401 Unauthorized]
    AUTH -->|ok| EP{Which endpoint?}

    %% ===========================
    %% POST / — Start / Resume
    %% ===========================
    EP -->|POST /| ST_V[validate RequestCreateGameSessionSchema]
    ST_V -->|invalid| E400[400 Bad Request]
    ST_V -->|valid| ST_START[gameService.start userId + levelId + currentElo + ip + userAgent]

    ST_START --> ST_CHECK{Active session exists for player?}
    ST_CHECK -->|yes, within RESUME_WINDOW_MS| ST_RESUME[Return existing session]
    ST_RESUME --> ST_LOG_R[log session:resumed]
    ST_LOG_R --> ST200[200 GameSession resumed=true]

    ST_CHECK -->|yes, but expired| ST_ABD[gameSessionService.abandon old session]
    ST_ABD --> ST_RECON[gameSessionService.reconcileAbandonedElo old session + currentElo]
    ST_RECON --> ST_NEW_LEVEL[levelService.getById levelId]

    ST_CHECK -->|no| ST_NEW_LEVEL

    ST_NEW_LEVEL --> ST_CREATE[gameSessionService.create userId + levelId + currentElo + maxAnswers + ip + userAgent]
    ST_CREATE --> ST_CACHE[leaderboardService.invalidateGlobal + invalidateByLevel]
    ST_CACHE --> ST_LOG_S[log session:started]
    ST_LOG_S --> ST201[201 GameSession created=true]

    %% ===========================
    %% POST /:id/answer
    %% ===========================
    EP -->|POST /:id/answer| AN_V[validate RequestAnswerSchema]
    AN_V -->|invalid| E400
    AN_V -->|valid| AN_SVC[gameService.answer sessionId + isCorrect + timeTakenMs]

    AN_SVC --> AN_GET[gameSessionService.getActiveById sessionId]
    AN_GET -->|not found| AN_404[404 Not Found]
    AN_GET -->|found| AN_MAX{Reached max_answers?}
    AN_MAX -->|yes| AN_MAX_ERR[409 Conflict — max answers reached]
    AN_MAX -->|no| AN_LVL[levelService.getById session.level_id]

    AN_LVL --> AN_CALC{"isCorrect?\n+ elo_gain_correct\n- elo_loss_incorrect"}
    AN_CALC --> AN_STATS[gameSessionService.updateStats score + streaks + eloDelta]
    AN_STATS --> AN_INSERT[gameSessionService.insertAnswer isCorrect + delta + timeTakenMs]
    AN_INSERT --> AN200[200 ResponseAnswer]

    %% ===========================
    %% POST /:id/end (completed)
    %% ===========================
    EP -->|POST /:id/end| END_SVC[gameService.end sessionId + userId + currentElo + status=completed]
    END_SVC --> END_GET[gameSessionService.getActiveById sessionId]
    END_GET -->|not found| END_404[404 Not Found]
    END_GET -->|found| END_NEXT[levelService.getNextActive afterId=session.level_id]

    END_NEXT --> END_ELO["finalElo = GREATEST(0, currentElo + session.elo_delta)"]
    END_ELO --> END_PAR["Parallel:\n1. gameSessionService.finalize status=completed elo_after=finalElo\n2. playerService.updateAfterSession\n3. eloService.append reason=session_completed"]
    END_PAR --> END_CACHE[leaderboardService.invalidateGlobal + invalidateByLevel]
    END_CACHE --> END_LOG[log session:ended + elo:updated]
    END_LOG --> END200[200 null]

    %% ===========================
    %% POST /:id/fail
    %% ===========================
    EP -->|POST /:id/fail| FAIL_SVC[gameService.end sessionId + userId + currentElo + status=failed]
    FAIL_SVC --> FAIL_GET[gameSessionService.getActiveById sessionId]
    FAIL_GET -->|not found| FAIL_404[404 Not Found]
    FAIL_GET -->|found| FAIL_NEXT[levelService.getNextActive — used for context only]
    FAIL_NEXT --> FAIL_ELO[finalElo = currentElo — no delta applied on fail]
    FAIL_ELO --> FAIL_PAR["Parallel:\n1. gameSessionService.finalize status=failed elo_after=currentElo\n2. playerService.updateAfterSession\n3. eloService.append reason=session_failed"]
    FAIL_PAR --> FAIL_CACHE[leaderboardService.invalidateGlobal + invalidateByLevel]
    FAIL_CACHE --> FAIL_LOG[log session:failed + elo:updated]
    FAIL_LOG --> FAIL200[200 null]

    %% ===========================
    %% POST /:id/abandon
    %% ===========================
    EP -->|POST /:id/abandon| ABD_SVC[gameService.abandon sessionId]
    ABD_SVC --> ABD_Q[gameSessionService.abandon — UPDATE status=abandoned ended_at=now]
    ABD_Q --> ABD_LOG[log session:abandoned]
    ABD_LOG --> ABD200[200 null]
```
