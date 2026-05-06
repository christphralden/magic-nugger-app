# Internal Route — Flowchart

All endpoints require `internal` middleware (not exposed to public clients).

## Endpoints
- `POST /memory` — server memory usage
- `POST /cache/leaderboard` — leaderboard cache state

```mermaid
flowchart TD
    REQ([Internal Client Request]) --> AUTH{internal middleware}
    AUTH -->|unauthorized| E401[401 Unauthorized]
    AUTH -->|ok| EP{Which endpoint?}

    %% --- POST /memory ---
    EP -->|POST /memory| MEM[process.memoryUsage]
    MEM --> MEM_FMT["Format bytes → MB x.xx MB\nrss, heapTotal, heapUsed, external, arrayBuffers"]
    MEM_FMT --> MEM200[200 memory stats object]

    %% --- POST /cache/leaderboard ---
    EP -->|POST /cache/leaderboard| CACHE[leaderboardCache.serialize]
    CACHE --> CACHE_LOG[console.log cache]
    CACHE_LOG --> CACHE200[200 cache state object]
```
