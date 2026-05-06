# Internal Route — Sequence Diagrams

All endpoints require `internal` middleware (not exposed to public clients).

## Endpoints
- `POST /memory` — server memory usage
- `POST /cache/leaderboard` — leaderboard cache state

```mermaid
sequenceDiagram
    participant IC as Internal Client
    participant R as InternalRouter
    participant MW as Middleware
    participant P as process
    participant CACHE as LeaderboardCache

    rect rgb(240, 248, 255)
        Note over IC,CACHE: POST /memory — Memory Stats
        IC->>R: POST /memory
        R->>MW: internal middleware
        MW-->>IC: 401 Unauthorized (if not internal)
        R->>P: process.memoryUsage()
        P-->>R: {rss, heapTotal, heapUsed, external, arrayBuffers} in bytes
        R->>R: format each field to "x.xx MB"
        R-->>IC: 200 {rss, heapTotal, heapUsed, external, arrayBuffers}
    end

    rect rgb(240, 255, 240)
        Note over IC,CACHE: POST /cache/leaderboard — Cache State
        IC->>R: POST /cache/leaderboard
        R->>MW: internal middleware
        MW-->>IC: 401 Unauthorized (if not internal)
        R->>CACHE: serialize()
        CACHE-->>R: cache state snapshot
        R->>R: console.log(cache state)
        R-->>IC: 200 {cache: state snapshot}
    end
```

## Notes

- The `internal` middleware restricts access to trusted internal callers only (e.g., health check systems, observability tooling).
- These endpoints are diagnostic — they expose server internals and must never be accessible from public internet.
