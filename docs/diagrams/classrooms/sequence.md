# Classrooms Route — Sequence Diagrams

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
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> ClassroomsRoute"
    participant CS as "<<service>> ClassroomService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. createClassroom(name, description, visibility, starting_elo, elo_cap)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(classroom:create)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestCreateClassroomSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>CS: 1.4. create(teacherId, body)
    CS->>CS: 1.4.1. generateInviteCode()
    CS->>DB: 1.4.2. query(Classroom)
    DB-->>CS: Classroom
    CS-->>R: Classroom
    R-->>C: 201 Classroom
```

## GET /

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> ClassroomsRoute"

    C->>R: 1. listClassrooms()
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R-->>C: 200 []
```

## GET /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> ClassroomsRoute"
    participant CS as "<<service>> ClassroomService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. getClassroom(classroomId)
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>CS: 1.2. getById(classroomId)
    CS->>DB: 1.2.1. query(Classroom)
    DB-->>CS: Classroom?
    alt not found
        CS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    CS-->>R: Classroom
    R-->>C: 200 Classroom
```

## PATCH /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> ClassroomsRoute"
    participant CS as "<<service>> ClassroomService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. updateClassroom(classroomId, name?, description?, visibility?, starting_elo?, elo_cap?)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(classroom:update)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestUpdateClassroomSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>DB: 1.4. query(Classroom)
    DB-->>R: {teacher_id}?
    alt teacher_id != user.id
        R-->>C: 403 Forbidden
    end
    R->>CS: 1.5. update(classroomId, body)
    CS->>DB: 1.5.1. query(Classroom)
    DB-->>CS: Classroom?
    alt not found
        CS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    CS-->>R: Classroom
    R-->>C: 200 Classroom
```

## DELETE /:id

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> ClassroomsRoute"
    participant CS as "<<service>> ClassroomService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. deleteClassroom(classroomId)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(classroom:delete)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>DB: 1.3. query(Classroom)
    DB-->>R: {teacher_id}?
    alt teacher_id != user.id
        R-->>C: 403 Forbidden
    end
    R->>CS: 1.4. delete(classroomId)
    CS->>DB: 1.4.1. query(Classroom)
    DB-->>CS: rowCount
    alt not found
        CS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    R-->>C: 200 null
```

## POST /join

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> ClassroomsRoute"
    participant CS as "<<service>> ClassroomService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. joinClassroom(invite_code)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(classroom:join)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>R: 1.3. validate(RequestJoinClassroomSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>CS: 1.4. join(playerId, invite_code)
    CS->>DB: 1.4.1. query(Classroom)
    DB-->>CS: {id, starting_elo}?
    alt invalid invite code
        CS-->>R: 404 NotFound
        R-->>C: 404 NotFound
    end
    CS->>DB: 1.4.2. query(ClassroomMember)
    DB-->>CS: ok
    R-->>C: 200 null
```

## DELETE /:id/leave

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> ClassroomsRoute"
    participant CS as "<<service>> ClassroomService"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. leaveClassroom(classroomId)
    R->>R: 1.1. authenticate()
    R->>R: 1.2. authorize(classroom:leave)
    alt unauthorized
        R-->>C: 401/403
    end
    R->>CS: 1.3. leave(playerId, classroomId)
    CS->>DB: 1.3.1. query(ClassroomMember)
    DB-->>CS: ok
    R-->>C: 200 null
```
