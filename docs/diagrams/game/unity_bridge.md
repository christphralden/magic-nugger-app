---
Date: 2026-05-14
Author: claude
Title: Unity ↔ Frontend Communication
---

# Unity ↔ Frontend Communication

Implemented via `use-unity-bridge.ts`. All Unity→FE communication uses browser custom events (`addEventListener`). All FE→Unity communication uses `sendMessage("ReactUnityCommunication", method, jsonPayload)`.

## Session Lifecycle

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant P  as "<<actor>> Player"
    participant FE as "<<hook>> useUnityBridge"
    participant U  as "<<runtime>> Unity WebGL"
    participant API as "<<controller>> GameRoute"

    P->>FE: mount Unity (after POST /game)
    Note over FE,U: Unity initialises

    U-->>FE: emit Init (void)
    FE->>U: sendMessage GiveInitialdata
    Note right of FE: { all_levels_unlocked: string[], current_elo: number } :: json

    Note over U: Level selector screen

    U-->>FE: emit Level (level_name: string)
    FE->>API: POST /game { level_name }
    API-->>FE: 201 GameSession

    Note over U: Game Phase begins

    loop until game phase ends
        U-->>FE: emit Answer (correct: boolean)
        FE->>API: POST /game/:id/answer { is_correct }
        API-->>FE: 200 ResponseAnswer
    end

    U-->>FE: emit Finished (alive: boolean)
    alt alive = true
        FE->>API: POST /game/:id/end
        API-->>FE: 200 { new_levels_unlocked }
    else alive = false
        FE->>API: POST /game/:id/fail
        API-->>FE: 200 { new_levels_unlocked }
    end

    FE->>U: sendMessage Finalized
    Note right of FE: { elo_gained: number, new_levels_unlocked: string[] } :: json
```

## Event Contract

| Direction    | Name              | Payload                                                        | When                        |
|--------------|-------------------|----------------------------------------------------------------|-----------------------------|
| Unity → FE   | `Init`            | void                                                           | Unity loaded and ready      |
| FE → Unity   | `GiveInitialdata` | `{ all_levels_unlocked: string[], current_elo: number }`       | On Init event               |
| Unity → FE   | `Level`           | `level_name: string`                                           | Player selects a level      |
| FE → API     | `POST /game`      | `{ level_name }`                                               | On Level event              |
| Unity → FE   | `Answer`          | `correct: boolean`                                             | Player submits an answer    |
| FE → API     | `POST /game/:id/answer` | `{ is_correct }`                                         | On Answer event             |
| Unity → FE   | `Finished`        | `alive: boolean`                                              | Game phase ends             |
| FE → API     | `POST /game/:id/end` or `/fail` | —                                                | alive true / false          |
| FE → Unity   | `Finalized`       | `{ elo_gained: number, new_levels_unlocked: string[] }`        | After session end or fail   |

> **Game Object**: All `sendMessage` calls target `"ReactUnityCommunication"`.  
> **Note**: `GiveInitialdata` is spelled with a lowercase `d` — matches the Unity C# method name exactly.
