# Room-Based Multiplayer — User Flow

Unity integration note: Unity is always given a `game_session_id` by the frontend. It calls the same single-player game endpoints regardless of whether the session is part of a room or not. Room logic is invisible to Unity.

---

## 1. Singleplayer Flow (unchanged)

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    SP_START([Player]) --> SP_LEVEL[FE: pick level]
    SP_LEVEL --> SP_CREATE["POST /game\n{ level_id }"]
    SP_CREATE --> SP_SESSION[receives game_session_id]
    SP_SESSION --> SP_UNITY[FE passes game_session_id to Unity]
    SP_UNITY --> SP_PLAY["Unity: POST /game/:id/answer\nper question"]
    SP_PLAY --> SP_MORE{more questions?}
    SP_MORE -->|yes| SP_PLAY
    SP_MORE -->|done — success| SP_END["Unity: POST /game/:id/end"]
    SP_MORE -->|done — fail| SP_FAIL["Unity: POST /game/:id/fail"]
    SP_END --> SP_ELO[ELO updated\nelo_history appended\nleaderboard invalidated]
    SP_FAIL --> SP_ELO
    SP_ELO --> SP_LB["GET /leaderboard/global\nor /leaderboard/levels/:id"]
```

---

## 2. Classroom Game Flow

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    T_START([Teacher]) --> T_PICK[FE: select classroom + level]
    T_PICK --> T_CREATE["POST /rooms/classroom\n{ level_id, classroom_id }"]
    T_CREATE --> T_ROOM[Room created — status: waiting\nreceives invite_code + room_id]

    T_ROOM --> T_SHARE[Teacher displays invite_code\nor students see room in active list]

    S_START([Student]) --> S_JOIN_OPT{join method}
    S_JOIN_OPT -->|invite code| S_JOIN_CODE["POST /rooms/join\n{ invite_code }"]
    S_JOIN_OPT -->|list| S_JOIN_LIST["GET /rooms\nfind classroom room"]
    S_JOIN_LIST --> S_JOIN_CODE
    S_JOIN_CODE --> S_LOBBY[Student enters lobby\nGET /rooms/:id — polling]

    T_SHARE --> S_START
    T_ROOM --> T_LOBBY[Teacher sees lobby\nGET /rooms/:id — polling]

    T_LOBBY --> T_READY{enough players?}
    T_READY -->|yes| T_START_ROOM["POST /rooms/:id/start\n(teacher / host only)"]
    T_START_ROOM --> ROOM_ACTIVE[Room status: in_progress\nall clients detect on next poll]

    S_LOBBY --> S_DETECT{poll detects\nin_progress?}
    S_DETECT -->|yes| S_CREATE_SESSION["POST /game\n{ level_id, room_id }"]
    ROOM_ACTIVE --> S_DETECT

    S_CREATE_SESSION --> S_SESSION[receives game_session_id\nroom_members.game_session_id updated]
    S_SESSION --> S_UNITY[FE passes game_session_id to Unity]

    T_LOBBY --> T_CREATE_SESSION["POST /game\n{ level_id, room_id }"]
    T_CREATE_SESSION --> T_SESSION[Teacher also plays\nor just monitors]

    S_UNITY --> S_PLAY["Unity: POST /game/:id/answer\nper question"]
    S_PLAY --> S_MORE{more questions?}
    S_MORE -->|yes| S_PLAY
    S_MORE -->|success| S_END["Unity: POST /game/:id/end"]
    S_MORE -->|fail| S_FAIL["Unity: POST /game/:id/fail"]
    S_END --> S_ELO[ELO updated\nroom member session finalized]
    S_FAIL --> S_ELO

    S_ELO --> S_WAIT[Student polls\nGET /rooms/:id\nwatching others finish]
    S_WAIT --> ALL_DONE{all members done?}
    ALL_DONE -->|auto| ROOM_DONE[Room auto-completes\nstatus: completed]
    ALL_DONE -->|host ends manually| T_END["POST /rooms/:id/end"]
    T_END --> ROOM_DONE

    ROOM_DONE --> LB["GET /leaderboard/rooms/:id\nshow room results"]
```

---

## 3. PVP Flow

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    H_START([Host Player]) --> H_CREATE["POST /rooms\n{ level_id }"]
    H_CREATE --> H_ROOM[Room created — status: waiting\nreceives invite_code + room_id]
    H_ROOM --> H_SHARE[Host shares invite_code\nout-of-band: chat, verbal, etc.]

    F_START([Friend]) --> F_JOIN["POST /rooms/join\n{ invite_code }"]
    H_SHARE --> F_START

    F_JOIN --> F_LOBBY[Friend in lobby\nGET /rooms/:id — polling]
    H_ROOM --> H_LOBBY[Host in lobby\nGET /rooms/:id — polling]

    H_LOBBY --> H_READY{friends joined?}
    H_READY -->|yes| H_START_ROOM["POST /rooms/:id/start\n(host only)"]
    H_START_ROOM --> ROOM_ACTIVE[Room status: in_progress]

    ROOM_ACTIVE --> BOTH_DETECT[All clients detect in_progress on poll]
    BOTH_DETECT --> H_SESSION["POST /game\n{ level_id, room_id }"]
    BOTH_DETECT --> F_SESSION["POST /game\n{ level_id, room_id }"]

    H_SESSION --> H_UNITY[Host game_session_id → Unity]
    F_SESSION --> F_UNITY[Friend game_session_id → Unity]

    H_UNITY --> H_PLAY[Unity plays independently]
    F_UNITY --> F_PLAY[Unity plays independently]

    H_PLAY --> H_END["POST /game/:id/end or /fail"]
    F_PLAY --> F_END["POST /game/:id/end or /fail"]

    H_END --> DONE[room auto-completes\nwhen all done]
    F_END --> DONE

    DONE --> LB["GET /leaderboard/rooms/:id"]
```

---

## 4. Room State Machine

```mermaid
%%{init: {'theme': 'neutral'}}%%
stateDiagram-v2
    direction LR

    [*] --> waiting : POST /rooms or POST /rooms/classroom
    waiting --> waiting : POST /rooms/join — player joins lobby
    waiting --> in_progress : POST /rooms/:id/start (host)\natomic — UPDATE WHERE status=waiting
    waiting --> cancelled : DELETE /rooms/:id (host)\nor cron cleanup after 2h
    in_progress --> in_progress : players create game sessions + play
    in_progress --> completed : all members finished\nor POST /rooms/:id/end (host)
    in_progress --> cancelled : DELETE /rooms/:id (host)\nor cron cleanup after 4h
    completed --> [*] : leaderboard available
    cancelled --> [*]
```

---

## 5. Unity Integration Summary

Unity only ever sees a single-player flow. Room membership is resolved entirely by the frontend before handing off to Unity.

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart LR
    FE[Frontend] -->|"game_session_id\n(from POST /game with optional room_id)"| UNITY[Unity Client]
    UNITY -->|"POST /game/:id/answer\n{ is_correct, time_taken_ms }"| API[API Server]
    UNITY -->|"POST /game/:id/end\nor /fail"| API
    API -->|ResponseAnswer| UNITY
    UNITY -->|score result| FE
    FE -->|"GET /leaderboard/rooms/:id\n(if room session)"| API
    FE -->|"GET /leaderboard/global\nor /levels/:id\n(if singleplayer)"| API
```

**Unity never calls room endpoints. FE handles all room state.**

---

## 6. Abandoned Session Recovery in Room

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    PLAYER([Player drops out]) --> CHECK_SESSION{POST /game with room_id}
    CHECK_SESSION --> EXISTING{existing in_progress session?}
    EXISTING -->|within 30-min window| RESUME[Resume same session\nroom_members.game_session_id unchanged]
    EXISTING -->|outside window| ABANDON_OLD[Old session abandoned\nELO reconciled]
    ABANDON_OLD --> NEW_SESSION[New session created\nroom_members.game_session_id updated\n— same transaction]
    RESUME --> UNITY[Pass game_session_id to Unity]
    NEW_SESSION --> UNITY
    EXISTING -->|none| NEW_SESSION2[New session created normally]
    NEW_SESSION2 --> UNITY
```
