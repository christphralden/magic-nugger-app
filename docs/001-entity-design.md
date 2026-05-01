Date: 01-05-2026 23:20:00
Author: christphralden
Title: 001-entity-design

---

# Magic Nugger Entity Relationship Design

Affected Services:

- web-app
- web-sever

---

# Preface

This is an education tower defence game. Age 6-12
Online game in a web using unity

Enemies are moving towards you, you need to solve math equations to defend against them
There will be n levels where each level the question gets gradually harder
Each player will have an elo associated with them
Each question will have a corresponding point that will contribute to your elo

# Database

- Relational
- Just use postgres probably
- No premature caching bcs we probably dont need that shit
- What about frequent writes? we are not going to scale so i think node can easily handle 100rps
- WAL? pretty overkill, lets get the base done and implement that later if needed.

# Web Server

- Just use node and express
- Typescript
- HTTP and probably use websocket to support any shit that comes

### Use case

> why even having a webserver?

handling authentication, authorization, user sessions and scoreboard

### Authentication

who doesnt have google right now? just use OAuth
or simple password sign-in

jwt? do we really wanna handle refresh tokens and shit? no. just use session i dont care

### Authorization

ur typical RBAC
roles: student, teacher / parent (i have no idea), admin

### User Sessions

> Concept

We have concepts of:

- Level: each stage is a level. it determines how hard the level and what questions are generated
- Elo: a point system that determines your level

Each player has an elo
Each level has a minimum elo

Punish wrong answers, while add correct answers

ELO

> What to track?

- How many question was answered correctly
- How many question was answered incorrectly
- How long is a streak of correct questions
- What else hmm?

### Leaderboard

We have a global and a level leaderboard

global: maxx elo
level: maxx points
