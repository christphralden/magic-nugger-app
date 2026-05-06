# Auth Route — Flowchart

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
flowchart TD
    START([POST /register]) --> V{validate RequestCreatePlayerSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| HASH[bcrypt.hash password]
    HASH --> DB[query Player]
    DB --> R201[201 ResponsePlayer]
```

## POST /login

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /login]) --> V{validate RequestLoginSchema}
    V -->|invalid| E400[400 BadRequest]
    V -->|valid| AUTH[authenticate local]
    AUTH --> DB[query Player]
    DB --> CMP{bcrypt.compare password}
    CMP -->|invalid| E401[401 Unauthorized]
    CMP -->|valid| SESSION[logIn user]
    SESSION --> LOG[log auth:login]
    LOG --> R200[200 ResponsePlayer]
```

## GET /oauth/google

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /oauth/google]) --> AUTH[authenticate google]
    AUTH --> REDIRECT[302 Redirect to Google OAuth]
```

## GET /oauth/google/callback

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /oauth/google/callback]) --> AUTH[authenticate google callback]
    AUTH --> DB[query Player upsert by oauth_id]
    DB --> CHECK{success?}
    CHECK -->|fail| FAIL[302 Redirect to /]
    CHECK -->|ok| SESSION[logIn user]
    SESSION --> LOG[log auth:oauth_login]
    LOG --> R302[302 Redirect to /levels]
```

## POST /logout

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([POST /logout]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| OUT[logout]
    OUT --> LOG[log auth:logout]
    LOG --> R200[200 null]
```

## GET /me

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
    START([GET /me]) --> AUTH{authenticate}
    AUTH -->|fail| E401[401 Unauthorized]
    AUTH -->|ok| MAP[toResponsePlayer user]
    MAP --> R200[200 ResponsePlayer]
```
