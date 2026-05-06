# Auth Route — Flowchart

## Endpoints
- `POST /register`
- `POST /login`
- `GET /oauth/google`
- `GET /oauth/google/callback`
- `POST /logout`
- `GET /me`

```mermaid
flowchart TD
    REQ([Client Request]) --> EP{Which endpoint?}

    %% --- REGISTER ---
    EP -->|POST /register| RV[validate RequestCreatePlayerSchema]
    RV -->|invalid| RV_ERR[400 Bad Request]
    RV -->|valid| RH[bcrypt.hash password, salt=12]
    RH --> RI[INSERT INTO players]
    RI --> R201[201 ResponsePlayer]

    %% --- LOGIN ---
    EP -->|POST /login| LV[validate RequestLoginSchema]
    LV -->|invalid| LV_ERR[400 Bad Request]
    LV -->|valid| LP[passport.authenticate local]
    LP -->|invalid credentials| LP_ERR[401 Unauthorized]
    LP -->|success| LLogin[req.logIn — establish session]
    LLogin --> LLog[log auth:login]
    LLog --> L200[200 ResponsePlayer]

    %% --- GOOGLE OAUTH INITIATE ---
    EP -->|GET /oauth/google| GO[passport.authenticate google]
    GO --> GO_R[Redirect → Google OAuth consent screen]

    %% --- GOOGLE OAUTH CALLBACK ---
    EP -->|GET /oauth/google/callback| CB[passport.authenticate google callback]
    CB -->|fail| CB_FAIL[Redirect → /]
    CB -->|success| CB_LOGIN[req.logIn — establish session]
    CB_LOGIN --> CB_LOG[log auth:oauth_login]
    CB_LOG --> CB_R[Redirect → /levels]

    %% --- LOGOUT ---
    EP -->|POST /logout| OUT_AUTH{authenticate}
    OUT_AUTH -->|not logged in| OUT_401[401 Unauthorized]
    OUT_AUTH -->|ok| OUT[req.logout — destroy session]
    OUT --> OUT_LOG[log auth:logout]
    OUT_LOG --> OUT200[200 null]

    %% --- ME ---
    EP -->|GET /me| ME_AUTH{authenticate}
    ME_AUTH -->|not logged in| ME_401[401 Unauthorized]
    ME_AUTH -->|ok| ME_MAP[toResponsePlayer req.user]
    ME_MAP --> ME200[200 ResponsePlayer]
```
