# Classrooms Route — Flowchart

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
flowchart TD
    REQ([Client Request]) --> AUTH{authenticate}
    AUTH -->|not logged in| E401[401 Unauthorized]
    AUTH -->|ok| EP{Which endpoint?}

    %% --- POST / (create) ---
    EP -->|POST /| C_AZ{authorize classroom:create}
    C_AZ -->|forbidden| E403[403 Forbidden]
    C_AZ -->|ok| C_V[validate RequestCreateClassroomSchema]
    C_V -->|invalid| E400[400 Bad Request]
    C_V -->|valid| C_SVC[classroomService.create teacherId + body]
    C_SVC --> C_GEN["Generate invite_code = UUID.slice(0,8).toUpperCase()"]
    C_GEN --> C_INS[INSERT INTO classrooms]
    C_INS --> C201[201 Classroom]

    %% --- GET / (list) ---
    EP -->|GET /| GL_RES["200 [] (TODO: filter by role)"]

    %% --- GET /:id ---
    EP -->|GET /:id| GI_SVC[classroomService.getById id]
    GI_SVC --> GI_Q["SELECT * FROM classrooms WHERE id=$1 AND is_active=true"]
    GI_Q -->|not found| GI_404[404 Not Found]
    GI_Q -->|found| GI200[200 Classroom]

    %% --- PATCH /:id (update) ---
    EP -->|PATCH /:id| U_AZ{authorize classroom:update}
    U_AZ -->|forbidden| E403
    U_AZ -->|ok| U_V[validate RequestUpdateClassroomSchema]
    U_V -->|invalid| E400
    U_V -->|valid| U_TEACH["SELECT teacher_id FROM classrooms WHERE id=$1"]
    U_TEACH -->|teacher_id != user.id| E403_T[403 Forbidden]
    U_TEACH -->|is teacher| U_SVC[classroomService.update id + body]
    U_SVC --> U_Q["UPDATE classrooms SET COALESCE fields WHERE id=$1 AND is_active=true"]
    U_Q -->|not found| U_404[404 Not Found]
    U_Q -->|updated| U200[200 Classroom]

    %% --- DELETE /:id (delete) ---
    EP -->|DELETE /:id| D_AZ{authorize classroom:delete}
    D_AZ -->|forbidden| E403
    D_AZ -->|ok| D_TEACH["SELECT teacher_id FROM classrooms WHERE id=$1"]
    D_TEACH -->|teacher_id != user.id| E403_D[403 Forbidden]
    D_TEACH -->|is teacher| D_SVC[classroomService.delete id]
    D_SVC --> D_Q["UPDATE classrooms SET is_active=false, updated_at=now()"]
    D_Q -->|not found| D_404[404 Not Found]
    D_Q -->|soft deleted| D200[200 null]

    %% --- POST /join ---
    EP -->|POST /join| J_AZ{authorize classroom:join}
    J_AZ -->|forbidden| E403
    J_AZ -->|ok| J_V[validate RequestJoinClassroomSchema]
    J_V -->|invalid| E400
    J_V -->|valid| J_SVC[classroomService.join playerId + inviteCode]
    J_SVC --> J_Q["SELECT id, starting_elo FROM classrooms WHERE invite_code=$1 AND is_active=true"]
    J_Q -->|not found| J_404[404 Invalid invite code]
    J_Q -->|found| J_INS["INSERT INTO classroom_members classroom_elo=starting_elo ON CONFLICT DO NOTHING"]
    J_INS --> J200[200 null]

    %% --- DELETE /:id/leave ---
    EP -->|DELETE /:id/leave| L_AZ{authorize classroom:leave}
    L_AZ -->|forbidden| E403
    L_AZ -->|ok| L_SVC[classroomService.leave playerId + classroomId]
    L_SVC --> L_Q[DELETE FROM classroom_members WHERE classroom_id=$1 AND player_id=$2]
    L_Q --> L200[200 null]
```
