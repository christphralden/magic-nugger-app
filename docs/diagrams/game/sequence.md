# Game Route — Sequence Diagrams

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
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> GameRoute"
    participant GS as "<<service>> GameService"
    participant GSS as "<<service>> GameSessionService"
    participant LS as "<<service>> LevelService"
    participant LBS as "<<service>> LeaderboardService"
    participant LOG as "<<service>> LoggingService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. startGame(levelId)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>R: 1.2. validate(RequestCreateGameSessionSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>GS: 1.3. start(userId, levelId, currentElo, ip, ua)
    GS->>GSS: 1.3.1. getActiveByPlayerId(userId)
    GSS->>DB: 1.3.1.1. query(GameSession)
    DB-->>GSS: GameSession?
    GSS-->>GS: GameSession?
    alt session exists within RESUME_WINDOW_MS
        GS-->>R: {session, created: false}
        R->>LOG: 1.3.2. log(session:resumed)
        R-->>C: 200 GameSession
    else session exists but expired
        GS->>GSS: 1.3.2. abandon(sessionId)
        GSS->>DB: 1.3.2.1. query(GameSession)
        DB-->>GSS: ok
        GS->>GSS: 1.3.3. reconcileAbandonedElo(session, currentElo)
        GSS->>DB: 1.3.3.1. query(GameSession, EloHistory)
        DB-->>GSS: ok
    end
    GS->>LS: 1.3.4. getById(levelId)
    LS->>DB: 1.3.4.1. query(Level)
    DB-->>LS: Level
    LS-->>GS: Level
    GS->>GSS: 1.3.5. create(userId, levelId, currentElo, maxAnswers, ip, ua)
    GSS->>DB: 1.3.5.1. query(GameSession)
    DB-->>GSS: GameSession
    GSS-->>GS: GameSession
    GS-->>R: {session, created: true}
    R->>LBS: 1.4. invalidateGlobal()
    R->>LBS: 1.5. invalidateByLevel(levelId)
    R->>LOG: 1.6. log(session:started)
    R-->>C: 201 GameSession
```

## POST /:id/answer

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> GameRoute"
    participant GS as "<<service>> GameService"
    participant GSS as "<<service>> GameSessionService"
    participant LS as "<<service>> LevelService"
    participant DB as "<<dataAccess>> Database"

    loop until max_answers reached or session ended
        C->>R: 1. submitAnswer(sessionId, is_correct, time_taken_ms?)
        R->>R: 1.1. authenticate()
        alt unauthenticated
            R-->>C: 401 Unauthorized
        end
        R->>R: 1.2. validate(RequestAnswerSchema)
        alt invalid payload
            R-->>C: 400 BadRequest
        end
        R->>GS: 1.3. answer(sessionId, isCorrect, timeTakenMs)
        GS->>GSS: 1.3.1. getActiveById(sessionId)
        GSS->>DB: 1.3.1.1. query(GameSession)
        DB-->>GSS: GameSession?
        GSS-->>GS: GameSession?
        alt not found or not in_progress
            GS-->>R: 404 NotFound
            R-->>C: 404 NotFound
        end
        alt max_answers reached
            GS-->>R: 409 Conflict
            R-->>C: 409 Conflict
        end
        GS->>LS: 1.3.2. getById(session.level_id)
        LS->>DB: 1.3.2.1. query(Level)
        DB-->>LS: Level
        LS-->>GS: Level
        GS->>GS: 1.3.3. computeDelta(isCorrect, elo_gain_correct, elo_loss_incorrect)
        GS->>GS: 1.3.4. computeStats(score, streak, maxStreak, eloDelta)
        par update session stats
            GS->>GSS: 1.3.5. updateStats(sessionId, score, correctCount, incorrectCount, currentStreak, maxStreak, eloDelta)
            GSS->>DB: 1.3.5.1. query(GameSession)
            DB-->>GSS: ok
        and insert answer record
            GS->>GSS: 1.3.6. insertAnswer(sessionId, isCorrect, delta, timeTakenMs)
            GSS->>DB: 1.3.6.1. query(SessionAnswer)
            DB-->>GSS: ok
        end
        GS-->>R: ResponseAnswer
        R-->>C: 200 ResponseAnswer
    end
```

## POST /:id/end

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> GameRoute"
    participant GS as "<<service>> GameService"
    participant GSS as "<<service>> GameSessionService"
    participant LS as "<<service>> LevelService"
    participant PS as "<<service>> PlayerService"
    participant ES as "<<service>> EloService"
    participant LBS as "<<service>> LeaderboardService"
    participant LOG as "<<service>> LoggingService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. endSession(sessionId)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>GS: 1.2. end(sessionId, userId, currentElo, status: completed)
    GS->>GSS: 1.2.1. getActiveById(sessionId)
    GSS->>DB: 1.2.1.1. query(GameSession)
    DB-->>GSS: GameSession?
    GSS-->>GS: GameSession?
    alt not found
        GS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    GS->>LS: 1.2.2. getNextActive(afterId: session.level_id)
    LS->>DB: 1.2.2.1. query(Level)
    DB-->>LS: Level?
    LS-->>GS: nextLevelId?
    GS->>GS: 1.2.3. computeFinalElo(currentElo, session.elo_delta)
    Note right of GS: finalElo = MAX(0, currentElo + elo_delta)
    par finalize session
        GS->>GSS: 1.2.4. finalize(sessionId, completed, finalElo)
        GSS->>DB: 1.2.4.1. query(GameSession)
        DB-->>GSS: ok
    and update player
        GS->>PS: 1.2.5. updateAfterSession(userId, eloDelta, completed, nextLevelId, stats)
        PS->>DB: 1.2.5.1. query(Player)
        DB-->>PS: ok
    and append elo history
        GS->>ES: 1.2.6. append(userId, sessionId, eloBefore, eloAfter, delta, session_completed)
        ES->>DB: 1.2.6.1. query(EloHistory)
        DB-->>ES: ok
    end
    GS-->>R: {levelId}
    R->>LBS: 1.3. invalidateGlobal()
    R->>LBS: 1.4. invalidateByLevel(levelId)
    R->>LOG: 1.5. log(session:ended)
    R->>LOG: 1.6. log(elo:updated)
    R-->>C: 200 null
```

## POST /:id/fail

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> GameRoute"
    participant GS as "<<service>> GameService"
    participant GSS as "<<service>> GameSessionService"
    participant LS as "<<service>> LevelService"
    participant PS as "<<service>> PlayerService"
    participant ES as "<<service>> EloService"
    participant LBS as "<<service>> LeaderboardService"
    participant LOG as "<<service>> LoggingService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. failSession(sessionId)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>GS: 1.2. end(sessionId, userId, currentElo, status: failed)
    GS->>GSS: 1.2.1. getActiveById(sessionId)
    GSS->>DB: 1.2.1.1. query(GameSession)
    DB-->>GSS: GameSession?
    GSS-->>GS: GameSession?
    alt not found
        GS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    GS->>LS: 1.2.2. getNextActive(afterId: session.level_id)
    LS->>DB: 1.2.2.1. query(Level)
    DB-->>LS: Level?
    Note right of GS: finalElo = currentElo — no delta applied on fail
    par finalize session
        GS->>GSS: 1.2.3. finalize(sessionId, failed, currentElo)
        GSS->>DB: 1.2.3.1. query(GameSession)
        DB-->>GSS: ok
    and update player stats
        GS->>PS: 1.2.4. updateAfterSession(userId, eloDelta: 0, failed, stats)
        PS->>DB: 1.2.4.1. query(Player)
        DB-->>PS: ok
    and append elo history
        GS->>ES: 1.2.5. append(userId, sessionId, delta: 0, session_failed)
        ES->>DB: 1.2.5.1. query(EloHistory)
        DB-->>ES: ok
    end
    GS-->>R: {levelId}
    R->>LBS: 1.3. invalidateGlobal()
    R->>LBS: 1.4. invalidateByLevel(levelId)
    R->>LOG: 1.5. log(session:failed)
    R->>LOG: 1.6. log(elo:updated)
    R-->>C: 200 null
```

## POST /:id/abandon

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> GameRoute"
    participant GS as "<<service>> GameService"
    participant GSS as "<<service>> GameSessionService"
    participant LOG as "<<service>> LoggingService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. abandonSession(sessionId)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>GS: 1.2. abandon(sessionId)
    GS->>GSS: 1.2.1. abandon(sessionId)
    GSS->>DB: 1.2.1.1. query(GameSession)
    DB-->>GSS: ok
    GS-->>R: void
    R->>LOG: 1.3. log(session:abandoned)
    R-->>C: 200 null
```

## Game Session State Machine

```mermaid
stateDiagram-v2
    [*] --> in_progress : POST /game (start)
    in_progress --> in_progress : POST /game (resume within window)
    in_progress --> completed : POST /game/:id/end
    in_progress --> failed : POST /game/:id/fail
    in_progress --> abandoned : POST /game/:id/abandon
    in_progress --> abandoned : POST /game (new start — old session expired)
    completed --> [*]
    failed --> [*]
    abandoned --> [*]
```
