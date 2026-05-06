# Classrooms Route — Flowchart

## Endpoints
- `POST /` — create classroom
- `GET /` — list classrooms
- `GET /:id` — get classroom
- `PATCH /:id` — update classroom
- `DELETE /:id` — delete classroom
- `POST /join` — join by invite code
- `DELETE /:id/leave` — leave classroom

---

## POST /

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize classroom:create}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestCreateClassroomSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| GEN[classroomService.create + generateInviteCode]
    GEN --> DB[query Classroom]
    DB --> R201[201 Classroom]
```

## GET /

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| R200[200 empty array]
```

## GET /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| SVC[classroomService.getById classroomId]
    SVC --> DB[query Classroom]
    DB --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 Classroom]
```

## PATCH /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([PATCH /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize classroom:update}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestUpdateClassroomSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| DB1[query Classroom for teacher_id]
    DB1 --> OWN{teacher_id == user.id?}
    OWN -->|no| E403_T[403 Forbidden]
    OWN -->|yes| SVC[classroomService.update classroomId + body]
    SVC --> DB2[query Classroom]
    DB2 --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| R200[200 Classroom]
```

## DELETE /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([DELETE /:id]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize classroom:delete}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| DB1[query Classroom for teacher_id]
    DB1 --> OWN{teacher_id == user.id?}
    OWN -->|no| E403_T[403 Forbidden]
    OWN -->|yes| SVC[classroomService.delete classroomId]
    SVC --> DB2[query Classroom soft delete]
    DB2 --> CHECK{found?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|deleted| R200[200 null]
```

## POST /join

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /join]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize classroom:join}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| V{validate RequestJoinClassroomSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| SVC[classroomService.join playerId + invite_code]
    SVC --> DB1[query Classroom by invite_code]
    DB1 --> CHECK{valid invite code?}
    CHECK -->|not found| E404[404 NotFound]
    CHECK -->|found| DB2[query ClassroomMember insert on conflict ignore]
    DB2 --> R200[200 null]
```

## DELETE /:id/leave

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([DELETE /:id/leave]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| AZ{authorize classroom:leave}
    AZ -->|forbidden| E403[403 Forbidden]
    AZ -->|ok| SVC[classroomService.leave playerId + classroomId]
    SVC --> DB[query ClassroomMember delete]
    DB --> R200[200 null]
```
