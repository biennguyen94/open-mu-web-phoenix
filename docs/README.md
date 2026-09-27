# Porting documentation

These documents were written during the port (2026-09-27) inside the Next.js repository
https://github.com/biennguyen94/open-mu-web, where this Phoenix application lived in the
`phoenix/` subdirectory. The history of this repository starts with that work (Phase 3; phases
0–2 are included in the first commit).

How to read the paths:

| In the docs | In this repository |
|---|---|
| `phoenix/<path>` (e.g. `phoenix/scripts/parity/run_all.sh`, `phoenix/deploy/`) | `<path>` (e.g. `scripts/parity/run_all.sh`, `deploy/`) |
| `app/**`, `lib/auth.ts`, `lib/prisma.ts`, `prisma/schema.prisma`, `public/img`, `.env` of the "current" app | files of the Next.js app in [open-mu-web](https://github.com/biennguyen94/open-mu-web) |
| "repository root `.env`" (shared with the Next.js app) | `.env` at the root of this repository (see `.env.example`) |

| Document | Content |
|---|---|
| [PORTING_STATUS.md](PORTING_STATUS.md) | status of every phase, decisions D1–D7, results, open questions |
| [PORTING_PLAN.md](PORTING_PLAN.md) | phases and checklists |
| [ARCHITECTURE.md](ARCHITECTURE.md) | architecture of the Next.js app and of the port, dependency mapping |
| [DATABASE.md](DATABASE.md) | OpenMU tables used, verified UUIDs, queries, Ecto strategy |
| [ROUTES.md](ROUTES.md), [API.md](API.md), [AUTH.md](AUTH.md), [FEATURES.md](FEATURES.md) | pages, API contracts (incl. intentional differences), authentication, features / character operations |
| [RISKS.md](RISKS.md) | security issues (R*), bugs (B*), porting risks (P*) |
| [DEPLOY.md](DEPLOY.md) | Docker deployment, operations, rollback |
| [db/openmu_schema.sql](db/openmu_schema.sql) | schema-only dump of the OpenMU database (reference) |
