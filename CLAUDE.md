# CLAUDE.md

OpenMU Web (Phoenix) — CMS website for a MU Online private server running [MUnique/OpenMU](https://github.com/MUnique/OpenMU).
Elixir/Phoenix port of the Next.js app https://github.com/biennguyen94/open-mu-web (the behavior reference; not part of this repository).
Read `docs/` before doing any work (start with `docs/README.md` and `docs/PORTING_STATUS.md`); do not re-analyze from scratch.

## Stacks

| | Stack | Status |
|---|---|---|
| **This repo** | Elixir 1.20 / OTP 28 + Phoenix 1.8 + LiveView + Ecto (postgrex), Tailwind v3 | Port complete (phases 0–7), **deployed**: container `openmu-web` on port 4000 (`deploy/`, `docs/DEPLOY.md`). See `AGENTS.md` for Phoenix coding rules. |
| **Database** | Existing OpenMU PostgreSQL database (schemas `config`, `data`, `friend`, `guild`, `public`), owned by the OpenMU game server (EF Core) | Shared with the running game server. |
| **Reference** | Next.js 16 + Prisma 7 + NextAuth v4 ([open-mu-web](https://github.com/biennguyen94/open-mu-web)) | Old implementation; used for parity checks (`scripts/parity/`). |

Decisions (details in `docs/PORTING_STATUS.md`): security issues fixed (no vulnerabilities ported) · game rules kept as in the Next.js app (reset stats base 20, reset keeps Experience/LevelUpPoints) · `/api/*` JSON endpoints kept · Tailwind v3 · default test accounts accepted (D7).

## Hard rules

1. **The OpenMU database is an existing production database.** Never run `mix ecto.drop/reset/create/setup/load/rollback` (they are blocked in `mix.exs`), `DROP`/`TRUNCATE`, or any migration that alters OpenMU tables.
2. The only website-owned table is `data."OpenMuWeb_News"`. Migrations are limited to it (`CREATE TABLE IF NOT EXISTS`) with `migration_source: "openmu_web_schema_migrations"`.
3. Keep behavior identical to the Next.js app (database semantics, game / ranking rules, auth, API contracts) unless a decision is recorded in `docs/PORTING_STATUS.md` → Decisions. Intentional differences: `docs/API.md` → "Intentional differences".
4. Docs label facts as **VERIFIED**, **NOT VERIFIED** or **ASSUMPTION**. Do not rely on NOT VERIFIED/ASSUMPTION items without checking.
5. Tests that write data use a disposable DB (`scripts/setup_test_db.sh`), never `openmu`. Read-only access to `openmu`: `PGOPTIONS='-c default_transaction_read_only=on'`. Reference schema: `docs/db/openmu_schema.sql`.
6. Never commit secrets: `.env` and `deploy/.env` are gitignored.

## Docs map

- `docs/README.md` — how to read the porting docs (written when this app lived in `phoenix/` of the Next.js repository)
- `docs/ARCHITECTURE.md`, `docs/DATABASE.md`, `docs/ROUTES.md`, `docs/API.md`, `docs/AUTH.md`, `docs/FEATURES.md` — behavior of the original app and of the port
- `docs/RISKS.md` — security issues, bugs, porting risks
- `docs/PORTING_PLAN.md`, `docs/PORTING_STATUS.md` — phases, decisions, results, open questions (update as work progresses)
- `docs/DEPLOY.md` — Docker deployment on WSL, operations, rollback
- `docs/VPS.md` — deploying to a VPS (configuration, ports, HTTPS, security)

## Commands

Toolchain in `~/.local/beam` (PATH set in `~/.bashrc`):
`mix setup` · `mix phx.server` (port 4001) · `scripts/setup_test_db.sh` then `mix test` · `mix precommit` · parity vs Next.js: `scripts/parity/run_all.sh` · deploy: `cd deploy && docker compose up -d --build`.
