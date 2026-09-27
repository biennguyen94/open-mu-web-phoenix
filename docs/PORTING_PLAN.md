# Porting plan: Next.js → Phoenix

Principle: port **behavior**, implement idiomatically in Elixir/Phoenix. Do not change DB semantics, game rules, ranking rules, auth behavior or API behavior without a recorded decision (`PORTING_STATUS.md`).
The OpenMU database is existing and shared with the game server — no destructive migrations, no drop/reset.

References: `ARCHITECTURE.md` (target structure, dependency mapping), `DATABASE.md` (tables, UUIDs, Ecto strategy), `API.md`, `AUTH.md`, `FEATURES.md`, `RISKS.md`.

## Repository layout (decision D6)

```text
open-mu-web/                 (this repo)
├── app/, lib/, prisma/, public/, package.json   Next.js app — unchanged, reference for parity
├── docs/                    shared documentation (+ docs/db/openmu_schema.sql)
├── CLAUDE.md
└── phoenix/                 Phoenix app (Mix app :open_mu_web, modules OpenMuWeb / OpenMuWebWeb)
    ├── lib/open_mu_web/     contexts + Ecto schemas
    ├── lib/open_mu_web_web/ router, controllers (incl. /api/*), LiveViews, components
    ├── priv/static/images/  copied from public/img
    ├── assets/              Tailwind v3 config with the current theme
    └── test/                ExUnit against a disposable DB copy
```

## Phase 0 — Analysis & DB verification — DONE (2026-09-27)

- [x] Source analysis → `docs/`.
- [x] Start `database` container; read-only queries on `openmu`.
- [x] `pg_dump --schema-only` → `docs/db/openmu_schema.sql`.
- [x] Verify attribute, class, map UUIDs; GM status 32; used table structures; `OpenMuWeb_News`.
- [x] Verify `session.user.id` at runtime (undefined → R3 confirmed).
- [x] Verify game server `/api/status` (shape + `text/plain`).
- [x] Check base stats per class (B3 discrepancy confirmed).
- [x] Exercise API behavior on a disposable clone (`openmu_phase0`).
- [x] Record decisions D1–D6.
- Not possible without a game client (moved to later phases): online-player rejection, game login with `$2b$` hash, in-game effect of reset.

## Phase 1 — Phoenix skeleton — DONE (2026-09-27)

- [x] Install Erlang/OTP 28.5 + Elixir 1.20.4 + phx_new 1.8.15 in user space (`~/.local/beam`).
- [x] `mix phx.new phoenix --app open_mu_web --module OpenMuWeb --binary-id --no-mailer`; destructive Ecto aliases blocked.
- [x] Repo → existing DB via `DATABASE_URL`; `migration_source: "openmu_web_schema_migrations"`; only the news-table guard migration.
- [x] `config/runtime.exs`: env vars (same names as Next.js) + dotenv fallback; `OpenMuWeb.Settings`.
- [x] Tailwind **v3** with the Next.js theme + `globals.css` rules; `public/img` → `priv/static/images`; Lora self-hosted.
- [x] Root layout: nav, secondary nav, banner slider, login/user panel slot, sidebar, footer, flash.
- [x] Test setup: `scripts/setup_test_db.sh` (full copy → `open_mu_web_test`), Ecto SQL sandbox, safety checks in `test_helper.exs`.

## Phase 2 — Read-only features — DONE (2026-09-27)

- [x] Ecto schemas: Account, Character, StatAttribute, ItemStorage, Guild, GuildMember, News.Article; `OpenMU.Ids`.
- [x] `GameServer` client (Req, explicit JSON decode, 5 s cache for the sidebar only).
- [x] Home news list (`?page=` working — intended behavior, see B2), news detail, Info, Download, Terms.
- [x] Sidebar: server status, top 10 characters, top 5 guilds.
- [x] `/ranking` LiveView: 4 tabs, guild member popup.
- [x] Read-only `/api/*` controllers: status, rankings (reset/killers/online), guilds, guild members.
- [x] Parity tests vs. Next.js responses (`phoenix/scripts/parity/`, results in PORTING_STATUS).

## Phase 3 — Authentication — DONE (2026-09-27)

- [x] Login/logout (controller POST/DELETE + encrypted cookie session), `fetch_current_account`, `require_authenticated`, `require_gm`, LiveView `on_mount`.
- [x] Register (same validation, messages, zod error JSON, defaults, status codes), Change Password (R1 fixed).
- [x] `/api/account/register`, `/api/account/changepassword`, `/api/auth/session`.
- [x] Verified: legacy `$2a$` accounts log in; accounts/passwords created by either app work on the other. Game-client login with `$2b$`: not verifiable without a client (source evidence only).

## Phase 4 — Character operations — DONE (2026-09-27)

- [x] `/characters` LiveView (pivot query, login required).
- [x] PK Clear, Add Stats, Reset Stats, Reset: transaction + `FOR UPDATE` on character and inventory, checks inside (R5), ownership by `AccountId` (R3), integer validation (R2), class from DB (R4), online check via `GameServer`.
- [x] Game rules unchanged (D2).
- [x] `/api/characters/*` controllers with the Next.js messages/status codes.
- [x] Integration tests on the disposable DB + side-by-side parity (`char_parity.py`) + live race test.

## Phase 5 — Admin — DONE (2026-09-27)

- [x] `/admin/news` (GM only, server-side), add news.
- [x] Delete news from the news cards with the confirmation dialog (`DELETE /admin/news/:id`).
- [x] `/api/admin/news` (POST) and `/api/admin/news/:id` (DELETE) with the Next.js messages/status codes; R3 fixed.
- [x] Tests + side-by-side parity (`admin_parity.py`).

## Phase 6 — API compatibility review — DONE (2026-09-27)

- [x] Inventory: every `app/api/**/route.ts` handler exists in Phoenix (plus `/api/auth/session`).
- [x] HTTP surface reproduced: 405 / OPTIONS (204 + `allow`) / HEAD / trailing-slash 308 / `Content-Type` without charset.
- [x] Final list of intentional differences in `API.md`.
- [x] `phoenix/scripts/parity/run_all.sh` runs every parity check in one command (+ `http_parity.py`).

## Phase 7 — Parity & cutover — DONE (2026-09-27)

- [x] Next.js and Phoenix side by side on DB copies (`run_all.sh`, Phase 6; all PASS).
- [x] Release image + compose (`phoenix/Dockerfile`, `phoenix/deploy/`), staging run on a DB copy.
- [x] Deployed on Docker (WSL) on the OpenMU network, port 4000; production smoke tests (read-only).
- [ ] Rotate DB credentials / untrack `.env` (R7) — needs a change in the OpenMU stack; not done.
- [ ] Announce re-login to users (sessions do not carry over).
- Follow-ups outside porting scope: B3 (per-class base stats), B4, B5, B14, B15, R11 (password length). R9 (default test accounts) accepted — D7.
