# Internal Route — Sequence Diagrams

## Endpoints
- `POST /memory` — server memory usage
- `POST /cache/leaderboard` — leaderboard cache state

---

## POST /memory

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant IC as "<<view>> InternalClient"
    participant R as "<<controller>> InternalRoute"
    participant RT as "<<service>> Runtime"

    IC->>R: 1. getMemoryStats()
    R->>R: 1.1. authorize(internal)
    alt unauthorized
        R-->>IC: 401 Unauthorized
    end
    R->>RT: 1.2. memoryUsage()
    RT-->>R: {rss, heapTotal, heapUsed, external, arrayBuffers}
    R->>R: 1.3. formatMemory(bytes)
    R-->>IC: 200 MemoryStats
```

## POST /cache/leaderboard

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant IC as "<<view>> InternalClient"
    participant R as "<<controller>> InternalRoute"
    participant CACHE as "<<cache>> LeaderboardCache"

    IC->>R: 1. getCacheState()
    R->>R: 1.1. authorize(internal)
    alt unauthorized
        R-->>IC: 401 Unauthorized
    end
    R->>CACHE: 1.2. serialize()
    CACHE-->>R: CacheSnapshot
    R-->>IC: 200 CacheSnapshot
```

## Notes

- The `internal` middleware restricts access to trusted internal callers only (e.g., health check systems, observability tooling).
- These endpoints are diagnostic — they expose server internals and must never be accessible from public internet.
