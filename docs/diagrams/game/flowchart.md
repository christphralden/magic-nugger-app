# Game Route — Flowchart

All endpoints require `authenticate`. No additional permission required.

## Endpoints
- `POST /` — start or resume game session
- `POST /:id/answer` — submit answer
- `POST /:id/end` — complete session (success)
- `POST /:id/fail` — fail session
- `POST /:id/abandon` — abandon session

---

## POST /

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| V{validate RequestCreateGameSessionSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| GET_S[gameSessionService.getActiveByPlayerId userId]
    GET_S --> S_CHECK{active session?}
    S_CHECK -->|within RESUME_WINDOW_MS| LOG_R[log session:resumed]
    LOG_R --> R200[200 GameSession resumed]
    S_CHECK -->|expired| ABD[gameSessionService.abandon sessionId]
    ABD --> RECON[gameSessionService.reconcileAbandonedElo session + currentElo]
    RECON --> GET_L[levelService.getById levelId]
    S_CHECK -->|none| GET_L
    GET_L --> CREATE[gameSessionService.create userId + levelId + currentElo]
    CREATE --> INV1[leaderboardService.invalidateGlobal]
    INV1 --> INV2[leaderboardService.invalidateByLevel levelId]
    INV2 --> LOG_S[log session:started]
    LOG_S --> R201[201 GameSession created]
```

## POST /:id/answer

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /:id/answer]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| V{validate RequestAnswerSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| GET_S[gameSessionService.getActiveById sessionId]
    GET_S --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| GET_L[levelService.getById session.level_id]
    GET_L --> CALC[computeDelta + computeStats isCorrect + elo config]
    CALC --> STATS[gameSessionService.updateStats score + streaks + eloDelta]
    CALC --> INS[gameSessionService.insertAnswer isCorrect + delta + timeTakenMs]
    STATS --> R200[200 ResponseAnswer]
    INS --> R200
```

## POST /:id/end

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /:id/end]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| GET_S[gameSessionService.getActiveById sessionId]
    GET_S --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| NEXT[levelService.getNextActive afterId]
    NEXT --> ELO[computeFinalElo: MAX 0 currentElo + elo_delta]
    ELO --> FIN[gameSessionService.finalize completed + finalElo]
    ELO --> UPD[playerService.updateAfterSession userId + eloDelta + stats]
    ELO --> HIST[eloService.append session_completed]
    ELO --> UNL[levelService.unlockChildLevels userId + level.child_levels]
    FIN --> INV1[leaderboardService.invalidateGlobal]
    UPD --> INV1
    HIST --> INV1
    UNL --> INV1
    INV1 --> INV2[leaderboardService.invalidateByLevel levelId]
    INV2 --> LOG1[log session:ended]
    LOG1 --> LOG2[log elo:updated]
    LOG2 --> R200[200 new_levels_unlocked]
```

## POST /:id/fail

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /:id/fail]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| GET_S[gameSessionService.getActiveById sessionId]
    GET_S --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| NEXT[levelService.getNextActive afterId]
    NEXT --> ELO[finalElo = currentElo — no delta on fail]
    ELO --> FIN[gameSessionService.finalize failed + currentElo]
    ELO --> UPD[playerService.updateAfterSession userId + eloDelta=0 + stats]
    ELO --> HIST[eloService.append session_failed delta=0]
    FIN --> INV1[leaderboardService.invalidateGlobal]
    UPD --> INV1
    HIST --> INV1
    INV1 --> INV2[leaderboardService.invalidateByLevel levelId]
    INV2 --> LOG1[log session:failed]
    LOG1 --> LOG2[log elo:updated]
    LOG2 --> R200[200 null]
```

## POST /:id/abandon

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /:id/abandon]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| SVC[gameSessionService.abandon sessionId]
    SVC --> LOG[log session:abandoned]
    LOG --> R200[200 null]
```
