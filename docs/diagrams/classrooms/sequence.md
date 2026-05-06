# Classrooms Route — Sequence Diagrams

All endpoints require `authenticate`. Specific endpoints additionally require `authorize(permission)`.

## Endpoints
- `POST /` — create classroom
- `GET /` — list classrooms
- `GET /:id` — get classroom
- `PATCH /:id` — update classroom
- `DELETE /:id` — delete classroom
- `POST /join` — join by invite code
- `DELETE /:id/leave` — leave classroom

```mermaid
sequenceDiagram
    participant C as Client
    participant R as ClassroomsRouter
    participant MW as Middleware
    participant CS as ClassroomService
    participant DB as Database

    rect rgb(240, 248, 255)
        Note over C,DB: POST / — Create Classroom
        C->>R: POST / {name, description, visibility, starting_elo, elo_cap}
        R->>MW: authenticate + authorize(classroom:create)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestCreateClassroomSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>CS: create(teacherId, body)
        CS->>CS: generate invite_code = UUID.slice(0,8).toUpperCase()
        CS->>DB: INSERT INTO classrooms (name, description, teacher_id, visibility, starting_elo, elo_cap, invite_code)
        DB-->>CS: Classroom row
        CS-->>R: Classroom
        R-->>C: 201 Classroom
    end

    rect rgb(240, 255, 240)
        Note over C,DB: GET / — List Classrooms
        C->>R: GET /
        R->>MW: authenticate
        MW-->>C: 401 (if unauthorized)
        R-->>C: 200 [] (TODO: filter by role)
    end

    rect rgb(255, 250, 240)
        Note over C,DB: GET /:id — Get Classroom
        C->>R: GET /:id
        R->>MW: authenticate
        MW-->>C: 401 (if unauthorized)
        R->>CS: getById(id)
        CS->>DB: SELECT * FROM classrooms WHERE id=$1 AND is_active=true
        DB-->>CS: Classroom or null
        CS-->>R: 404 AppError (if null)
        CS-->>R: Classroom
        R-->>C: 200 Classroom
    end

    rect rgb(255, 240, 255)
        Note over C,DB: PATCH /:id — Update Classroom
        C->>R: PATCH /:id {name?, description?, visibility?, starting_elo?, elo_cap?}
        R->>MW: authenticate + authorize(classroom:update)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestUpdateClassroomSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>DB: SELECT teacher_id FROM classrooms WHERE id=$1
        DB-->>R: {teacher_id}
        R-->>C: 403 Forbidden (if teacher_id != user.id)
        R->>CS: update(id, body)
        CS->>DB: UPDATE classrooms SET COALESCE(fields) WHERE id=$1 AND is_active=true
        DB-->>CS: Updated Classroom or null
        CS-->>R: 404 AppError (if null)
        CS-->>R: Classroom
        R-->>C: 200 Classroom
    end

    rect rgb(240, 255, 255)
        Note over C,DB: DELETE /:id — Delete Classroom (soft)
        C->>R: DELETE /:id
        R->>MW: authenticate + authorize(classroom:delete)
        MW-->>C: 401/403 (if unauthorized)
        R->>DB: SELECT teacher_id FROM classrooms WHERE id=$1
        DB-->>R: {teacher_id}
        R-->>C: 403 Forbidden (if teacher_id != user.id)
        R->>CS: delete(id)
        CS->>DB: UPDATE classrooms SET is_active=false, updated_at=now() WHERE id=$1
        DB-->>CS: rowCount
        CS-->>R: 404 AppError (if rowCount=0)
        R-->>C: 200 null
    end

    rect rgb(255, 255, 240)
        Note over C,DB: POST /join — Join Classroom
        C->>R: POST /join {invite_code}
        R->>MW: authenticate + authorize(classroom:join)
        MW-->>C: 401/403 (if unauthorized)
        R->>MW: validate(RequestJoinClassroomSchema)
        MW-->>C: 400 Bad Request (if invalid)
        R->>CS: join(playerId, invite_code)
        CS->>DB: SELECT id, starting_elo FROM classrooms WHERE invite_code=$1 AND is_active=true
        DB-->>CS: {id, starting_elo} or null
        CS-->>R: 404 AppError "Invalid invite code" (if null)
        CS->>DB: INSERT INTO classroom_members (classroom_id, player_id, classroom_elo=starting_elo) ON CONFLICT DO NOTHING
        DB-->>CS: ok
        R-->>C: 200 null
    end

    rect rgb(248, 240, 255)
        Note over C,DB: DELETE /:id/leave — Leave Classroom
        C->>R: DELETE /:id/leave
        R->>MW: authenticate + authorize(classroom:leave)
        MW-->>C: 401/403 (if unauthorized)
        R->>CS: leave(playerId, classroomId)
        CS->>DB: DELETE FROM classroom_members WHERE classroom_id=$1 AND player_id=$2
        DB-->>CS: ok (idempotent)
        R-->>C: 200 null
    end
```
