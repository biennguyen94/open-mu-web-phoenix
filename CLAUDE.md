# CLAUDE.md

OpenMU Web — CMS website for a MU Online private server running [MUnique/OpenMU](https://github.com/MUnique/OpenMU).
This repository is being **ported** to Elixir/Phoenix. Read `docs/` before doing any work; do not re-analyze the repo from scratch.

## Stacks

| | Stack | Status |
|---|---|---|
| **Current** | Next.js 16 (App Router) + React 19 + TypeScript + Prisma 7 (`@prisma/adapter-pg`) + NextAuth v4 + Tailwind 3 | Source of truth for behavior. Do not modify during porting. |
| **Existing** | OpenMU PostgreSQL database (schemas `config`, `data`, `friend`, `guild`, `public`), owned by the OpenMU game server (EF Core) | Shared with the running game server. |
| **Target** | Elixir + Phoenix + LiveView + Ecto (postgrex), Tailwind v3 | Lives in `phoenix/` (Mix app `:open_mu_web`). Phases 1–3 (skeleton, read-only features, authentication) done; see `docs/PORTING_STATUS.md` and `phoenix/AGENTS.md`. |

Decisions (details in `docs/PORTING_STATUS.md`): fix security issues (R1–R3, no vulnerabilities ported) · keep current game rules (reset stats base 20, reset keeps Experience/LevelUpPoints) · keep `/api/*` JSON endpoints · Tailwind v3 · Phoenix in `phoenix/` next to the untouched Next.js app.

## Hard rules

1. **The OpenMU database is an existing production database.** Never run `mix ecto.drop`, `mix ecto.reset`, `mix ecto.create` against it, `prisma db push`, `prisma migrate`, `DROP`/`TRUNCATE`, or any migration that alters OpenMU tables.
2. The only website-owned table is `data."OpenMuWeb_News"`. Any Ecto migration must be limited to it (`CREATE TABLE IF NOT EXISTS`) and must use a separate `migration_source`.
3. Port **behavior**, not TypeScript line-by-line. Do not change database semantics, game rules (reset/stats/PK), ranking rules, auth behavior or API behavior unless the decision is recorded in `docs/PORTING_STATUS.md` → Decisions.
4. Docs label facts as **VERIFIED** (checked against the running DB / app on 2026-09-27), **NOT VERIFIED** or **ASSUMPTION**. Do not rely on NOT VERIFIED/ASSUMPTION items without checking.
5. Tests that write data must use a disposable DB (clone/restore), never `openmu`. Read-only access to `openmu`: `PGOPTIONS='-c default_transaction_read_only=on'`. Reference schema dump: `docs/db/openmu_schema.sql`.
6. Never commit secrets. `.env` is currently tracked in git and contains `DATABASE_URL` and `NEXTAUTH_SECRET`; do not copy its values into docs or code.
7. Do not modify the Next.js application code unless explicitly asked. Note: running `next dev` re-inserts the `nextjs-agent-rules` block below; it applies only to the Next.js app.

## Docs map

- `docs/ARCHITECTURE.md` — current architecture, proposed Phoenix architecture, dependency mapping
- `docs/DATABASE.md` — tables used, hard-coded UUIDs, queries, Ecto strategy
- `docs/ROUTES.md` — page routes
- `docs/API.md` — API endpoints
- `docs/AUTH.md` — authentication/authorization flow
- `docs/FEATURES.md` — feature list and character operations
- `docs/RISKS.md` — security issues, bugs, porting risks
- `docs/PORTING_PLAN.md` — phases
- `docs/PORTING_STATUS.md` — current status, decisions, open questions (update this as work progresses)

## Commands

Next.js (reference): `npm run dev` · `npm run build` (runs `prisma generate`) · `npm start` (port 4000) · `npx tsc --noEmit`

Phoenix (`cd phoenix`, toolchain in `~/.local/beam`, PATH set in `~/.bashrc`): `mix setup` · `mix phx.server` (port 4001) · `scripts/setup_test_db.sh` then `mix test` · `mix precommit` · parity vs Next.js: `phoenix/scripts/parity/README.md`. `mix ecto.create/drop/reset/setup/load/rollback` are intentionally blocked.

<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
