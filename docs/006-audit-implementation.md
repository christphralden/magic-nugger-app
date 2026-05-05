---
Date: 2026-05-06
Author: christphralden
Title: 006-audit-implementation
---

## Overview

Every HTTP request is logged to `audit.audit_events` for security auditing. The table is range-partitioned by month using `pg_partman` so query performance stays constant as it grows.

---

## Schema

```sql
audit.audit_events (
  id          UUID         PK (composite with created_at)
  user_id     UUID         FK → players(id) ON DELETE SET NULL  -- null on unauthenticated requests
  url         VARCHAR(255) -- endpoint relative to /api, e.g. /v1/auth/login
  status_code SMALLINT     -- HTTP response status
  ip_address  INET
  user_agent  TEXT
  metadata    JSONB        -- sanitized request body, only populated on status >= 400
  created_at  TIMESTAMPTZ  DEFAULT now()
  http_method VARCHAR(10) DEFAULT NULL -- HTTP method
)
PARTITION BY RANGE (created_at)
```

`metadata` strips sensitive keys (`password`, `token`, `secret`, `authorization`, `sess`, `session`, `cookie`) before storing.

---

## Partitioning

`audit.audit_events` is a monthly range-partitioned table managed by `pg_partman`.

- Partition key: `created_at`
- Interval: 1 month
- Premake: 3 (BGW maintains 3 future partitions ahead of current month)
- BGW runs every 3600s as `partman_user`, checks existing partitions, creates only what is missing

New partitions inherit all indexes from the parent automatically.

### Roles

| Role           | Privileges on `audit`                                    |
| -------------- | -------------------------------------------------------- |
| `partman_user` | ALL on schema + table owner — creates/manages partitions |
| `app`          | INSERT only — write-only, cannot read audit data         |

`ALTER DEFAULT PRIVILEGES FOR ROLE partman_user IN SCHEMA audit GRANT INSERT ON TABLES TO app` ensures INSERT is automatically granted on every new partition `partman_user` creates.

---

## Middleware

`web-server/src/middleware/audit.ts` runs after `passport.session()` on every request.

```
request in
  → capture user_id, ip, user_agent, url before next()
  → next() → route handler executes → response sent
  → res.on("finish") fires
      → read status_code from res
      → if status >= 400: attach sanitized req.body as metadata
      → INSERT into audit.audit_events (fire-and-forget)
```

`user_id` is captured before `next()` so logout requests (which clear `req.user`) are still attributed to the correct player.

Audit failures are logged to stderr and never surface to the client.

---

## Migrations

| Migration                                      | What it does                                                 |
| ---------------------------------------------- | ------------------------------------------------------------ |
| `202605020012_create_pg_partman`               | Creates `partman` schema, installs extension, creates role   |
| `202605020013_create_audit_events`             | Creates `audit` schema, partitioned table, registers partman |
| `202605060001_update_audit_events_http_method` | Updates `audit` schema to have `http_method`                 |

---

## Infrastructure

`db/Dockerfile` builds `postgres:16-alpine` with `pg_partman` compiled from source (pinned commit `a12b23e`) using `clang19`/`llvm19-dev` to match the LLVM version PG16 Alpine was compiled with.

`db/init/002_extensions.sh` runs once on volume init and adds `LOGIN` + `PASSWORD` to `partman_user` (password from `PARTMAN_PASSWORD` env var). The migration creates the role without login as a fallback for environments where the init script does not run.
