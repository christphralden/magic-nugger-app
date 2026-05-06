# Game Route — Sequence Diagrams

All endpoints require `authenticate`. No additional permission required.

## Endpoints
- `POST /` — start or resume game session
- `POST /:id/answer` — submit answer
- `POST /:id/end` — complete session (success)
- `POST /:id/fail` — fail session
- `POST /:id/abandon` — abandon session

```mermaid
sequenceDiagram
    participant C as Client
    participant R as GameRouter
    participant MW as Middleware
    participant GS as GameService
    participant GSS as GameSessionService
    participant LS as LevelService
    participant PS as PlayerService
    participant ES as EloService
    participant LBS as LeaderboardService
    participant LOG as LoggingService
    participant DB as Database

    rect rgb(240, 248, 255)
        Note over C,DB: POST / — Start or Resume Game Session
        C->>R: POST / {level_id}
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>MW: validate(RequestCreateGameSessionSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>GS: start({userId, levelId, currentElo, ip, userAgent})
        GS->>GSS: getActiveByPlayerId({userId})
        DB-->>GSS: existing GameSession or null

        alt Session exists within RESUME_WINDOW_MS
            GS-->>R: {session: existing, created: false}
            R->>LOG: log(session:resumed)
            R-->>C: 200 GameSession
        else Session exists but expired
            GS->>GSS: abandon({sessionId: old})
            GSS->>DB: UPDATE game_sessions SET status=abandoned, ended_at=now()
            GS->>GSS: reconcileAbandonedElo({session: old, currentElo})
            GSS->>DB: UPDATE game_sessions SET elo_after + INSERT elo_history(reason=session_abandoned)
            DB-->>GSS: ok
        end

        GS->>LS: getById(levelId)
        LS->>DB: SELECT * FROM levels WHERE id=$1 AND is_active=true
        DB-->>LS: Level
        GS->>GSS: create({userId, levelId, currentElo, maxAnswers, ip, userAgent})
        GSS->>DB: INSERT INTO game_sessions
        DB-->>GSS: GameSession
        GS-->>R: {session: new, created: true}
        R->>LBS: invalidateGlobal() + invalidateByLevel(levelId)
        R->>LOG: log(session:started)
        R-->>C: 201 GameSession
    end

    rect rgb(240, 255, 240)
        Note over C,DB: POST /:id/answer — Submit Answer
        C->>R: POST /:id/answer {is_correct, time_taken_ms?}
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>MW: validate(RequestAnswerSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>GS: answer({sessionId, isCorrect, timeTakenMs})
        GS->>GSS: getActiveById({sessionId})
        GSS->>DB: SELECT * FROM game_sessions WHERE id=$1 AND status=in_progress
        DB-->>GSS: GameSession or null
        GS-->>R: 404 (if null)
        GS->>GS: check session.answers_count < max_answers
        GS-->>R: 409 Conflict (if max reached)
        GS->>LS: getById(session.level_id)
        DB-->>LS: Level (elo_gain_correct, elo_loss_incorrect)
        GS->>GS: delta = isCorrect ? +elo_gain_correct : -elo_loss_incorrect
        GS->>GS: compute newScore, newStreak, newMaxStreak, newEloDelta
        par
            GS->>GSS: updateStats({sessionId, score, correctCount, incorrectCount, currentStreak, maxStreak, eloDelta})
            GSS->>DB: UPDATE game_sessions SET stats
        and
            GS->>GSS: insertAnswer({sessionId, isCorrect, delta, timeTakenMs})
            GSS->>DB: INSERT INTO session_answers
        end
        GS-->>R: ResponseAnswer {is_correct, elo_delta, current_streak, current_score}
        R-->>C: 200 ResponseAnswer
    end

    rect rgb(255, 250, 240)
        Note over C,DB: POST /:id/end — Complete Session
        C->>R: POST /:id/end
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>GS: end({sessionId, userId, currentElo, status: "completed"})
        GS->>GSS: getActiveById({sessionId})
        DB-->>GSS: GameSession or null
        GS-->>R: 404 (if null)
        GS->>LS: getNextActive({afterId: session.level_id})
        DB-->>LS: nextLevelId or null
        GS->>GS: finalElo = GREATEST(0, currentElo + session.elo_delta)
        par
            GS->>GSS: finalize({sessionId, status: "completed", finalElo})
            GSS->>DB: UPDATE game_sessions SET status=completed, elo_after=finalElo, ended_at=now()
        and
            GS->>PS: updateAfterSession({userId, eloDelta, status, nextLevelId, totalAnswered, totalCorrect, totalIncorrect, maxStreak})
            PS->>DB: UPDATE players SET current_elo, highest_level_unlocked, stats, last_active_at
        and
            GS->>ES: append({userId, sessionId, eloBefore, eloAfter, delta, reason: "session_completed"})
            ES->>DB: INSERT INTO elo_history
        end
        GS-->>R: {levelId}
        R->>LBS: invalidateGlobal() + invalidateByLevel(levelId)
        R->>LOG: log(session:ended) + log(elo:updated)
        R-->>C: 200 null
    end

    rect rgb(255, 240, 255)
        Note over C,DB: POST /:id/fail — Fail Session
        C->>R: POST /:id/fail
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>GS: end({sessionId, userId, currentElo, status: "failed"})
        GS->>GSS: getActiveById({sessionId})
        DB-->>GSS: GameSession or null
        GS-->>R: 404 (if null)
        GS->>LS: getNextActive({afterId: session.level_id})
        DB-->>LS: nextLevelId (not applied on fail)
        GS->>GS: finalElo = currentElo (no delta on fail)
        par
            GS->>GSS: finalize({sessionId, status: "failed", finalElo: currentElo})
            GSS->>DB: UPDATE game_sessions SET status=failed, elo_after=currentElo, ended_at=now()
        and
            GS->>PS: updateAfterSession({userId, eloDelta, status: "failed", ...})
            PS->>DB: UPDATE players SET stats (elo unchanged)
        and
            GS->>ES: append({userId, sessionId, delta=0, reason: "session_failed"})
            ES->>DB: INSERT INTO elo_history
        end
        GS-->>R: {levelId}
        R->>LBS: invalidateGlobal() + invalidateByLevel(levelId)
        R->>LOG: log(session:failed) + log(elo:updated)
        R-->>C: 200 null
    end

    rect rgb(240, 255, 255)
        Note over C,DB: POST /:id/abandon — Abandon Session
        C->>R: POST /:id/abandon
        R->>MW: authenticate
        MW-->>C: 401 (if not logged in)
        R->>GS: abandon({sessionId})
        GS->>GSS: abandon({sessionId})
        GSS->>DB: UPDATE game_sessions SET status=abandoned, ended_at=now() WHERE id=$1
        DB-->>GSS: ok
        GS-->>R: void
        R->>LOG: log(session:abandoned)
        R-->>C: 200 null
    end
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
