# Auth Route — Sequence Diagrams

## Endpoints
- `POST /register`
- `POST /login`
- `GET /oauth/google`
- `GET /oauth/google/callback`
- `POST /logout`
- `GET /me`

```mermaid
sequenceDiagram
    participant C as Client
    participant R as AuthRouter
    participant V as Validate
    participant P as Passport
    participant S as Session
    participant DB as Database
    participant L as LoggingService

    rect rgb(240, 248, 255)
        Note over C,L: POST /register
        C->>R: POST /register {username, email, password, display_name}
        R->>V: validate(RequestCreatePlayerSchema)
        V-->>C: 400 Bad Request (if invalid)
        R->>R: bcrypt.hash(password, 12)
        R->>DB: INSERT INTO players
        DB-->>R: Player row
        R-->>C: 201 ResponsePlayer
    end

    rect rgb(240, 255, 240)
        Note over C,L: POST /login
        C->>R: POST /login {username, password}
        R->>V: validate(RequestLoginSchema)
        V-->>C: 400 Bad Request (if invalid)
        R->>P: passport.authenticate("local")
        P->>DB: SELECT player WHERE username=$1
        DB-->>P: Player row or null
        P->>P: bcrypt.compare(password, hash)
        P-->>C: 401 Unauthorized (if credentials invalid)
        R->>S: req.logIn(user)
        R->>L: log(auth:login, userId, email)
        R-->>C: 200 ResponsePlayer
    end

    rect rgb(255, 250, 240)
        Note over C,L: GET /oauth/google
        C->>R: GET /oauth/google
        R->>P: passport.authenticate("google", {scope: [profile, email]})
        P-->>C: 302 Redirect → Google OAuth
    end

    rect rgb(255, 240, 255)
        Note over C,L: GET /oauth/google/callback
        C->>R: GET /oauth/google/callback?code=...
        R->>P: passport.authenticate("google")
        P->>DB: Upsert player by oauth_provider + oauth_id
        DB-->>P: Player row
        P-->>C: 302 Redirect → / (if fail)
        R->>S: req.logIn(user)
        R->>L: log(auth:oauth_login, userId, email)
        R-->>C: 302 Redirect → /levels
    end

    rect rgb(240, 255, 255)
        Note over C,L: POST /logout
        C->>R: POST /logout
        R->>R: authenticate middleware
        R-->>C: 401 Unauthorized (if not logged in)
        R->>S: req.logout()
        R->>L: log(auth:logout, userId)
        R-->>C: 200 null
    end

    rect rgb(255, 255, 240)
        Note over C,L: GET /me
        C->>R: GET /me
        R->>R: authenticate middleware
        R-->>C: 401 Unauthorized (if not logged in)
        R->>R: toResponsePlayer(req.user)
        R-->>C: 200 ResponsePlayer
    end
```
