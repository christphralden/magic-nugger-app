# Auth Route — Sequence Diagrams

## Endpoints
- `POST /register`
- `POST /login`
- `GET /oauth/google`
- `GET /oauth/google/callback`
- `POST /logout`
- `GET /me`

---

## POST /register

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AuthRoute"
    participant DB as "<<dataAccess>> Database"

    C->>R: 1. register(username, email, password, display_name)
    R->>R: 1.1. validate(RequestCreatePlayerSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>R: 1.2. bcrypt.hash(password)
    R->>DB: 1.3. query(Player)
    DB-->>R: Player
    R-->>C: 201 ResponsePlayer
```

## POST /login

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AuthRoute"
    participant PASS as "<<service>> PassportStrategy"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    C->>R: 1. login(username, password)
    R->>R: 1.1. validate(RequestLoginSchema)
    alt invalid payload
        R-->>C: 400 BadRequest
    end
    R->>PASS: 1.2. authenticate(local, username, password)
    PASS->>DB: 1.2.1. query(Player)
    DB-->>PASS: Player?
    PASS->>PASS: 1.2.2. bcrypt.compare(password, hash)
    alt invalid credentials
        PASS-->>R: 401 Unauthorized
        R-->>C: 401 Unauthorized
    end
    PASS-->>R: Player
    R->>R: 1.3. logIn(user)
    R->>LOG: 1.4. log(auth:login)
    R-->>C: 200 ResponsePlayer
```

## GET /oauth/google

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AuthRoute"
    participant PASS as "<<service>> PassportStrategy"

    C->>R: 1. oauthGoogle()
    R->>PASS: 1.1. authenticate(google, scopes)
    PASS-->>C: 302 Redirect → Google OAuth
```

## GET /oauth/google/callback

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AuthRoute"
    participant PASS as "<<service>> PassportStrategy"
    participant DB as "<<dataAccess>> Database"
    participant LOG as "<<service>> LoggingService"

    C->>R: 1. oauthGoogleCallback(code)
    R->>PASS: 1.1. authenticate(google)
    PASS->>DB: 1.1.1. query(Player)
    DB-->>PASS: Player
    alt authentication failed
        PASS-->>R: failure
        R-->>C: 302 Redirect → /
    end
    PASS-->>R: Player
    R->>R: 1.2. logIn(user)
    R->>LOG: 1.3. log(auth:oauth_login)
    R-->>C: 302 Redirect → /levels
```

## POST /logout

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AuthRoute"
    participant LOG as "<<service>> LoggingService"

    C->>R: 1. logout()
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>R: 1.2. logout()
    R->>LOG: 1.3. log(auth:logout)
    R-->>C: 200 null
```

## GET /me

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    participant C as "<<view>> Client"
    participant R as "<<controller>> AuthRoute"

    C->>R: 1. me()
    R->>R: 1.1. authenticate()
    alt unauthenticated
        R-->>C: 401 Unauthorized
    end
    R->>R: 1.2. toResponsePlayer(user)
    R-->>C: 200 ResponsePlayer
```
