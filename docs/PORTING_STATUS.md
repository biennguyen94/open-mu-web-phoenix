# Porting status

Last updated: 2026-09-27

| Phase | Name | Status |
|---|---|---|
| 0 | Analysis / DB verification | **DONE** (2026-09-27) — items requiring a game client deferred (see below) |
| 1 | Phoenix skeleton | **DONE** (2026-09-27) |
| 2 | Read-only features | **DONE** (2026-09-27) |
| 3 | Authentication | **DONE** (2026-09-27) |
| 4 | Character operations | **DONE** (2026-09-27) |
| 5 | Admin | **DONE** (2026-09-27) |
| 6 | API compatibility review | **DONE** (2026-09-27) |
| 7 | Parity & cutover | TODO |

Phoenix app in `phoenix/`: skeleton (Phase 1), read-only features (Phase 2), authentication (Phase 3), character operations (Phase 4), admin news (Phase 5), API compatibility review (Phase 6). The Next.js application code has not been modified. The DB `openmu` has not been written by Phoenix (no migrations run against it; verified `public.openmu_web_schema_migrations` does not exist there).

## Decisions

| # | Question | Decision (2026-09-27) |
|---|---|---|
| D1 | Security | **Fix R1, R2, R3** in Phoenix; do not port security vulnerabilities. Under the same principle Phoenix also fixes R4 (class from DB), R5 (atomic checks), R6 (server-side guards); for legitimate requests results are identical. |
| D2 | Game rules | **Behavioral parity**: keep current rules in the first port — Reset Stats uses base 20; Reset does not change Experience or LevelUpPoints. Discrepancies with OpenMU are recorded (B3, B4) and handled separately; no scope expansion. |
| D3 | API | **Keep all `/api/*` JSON endpoints** during the port for compatibility and testing. None removed. |
| D4 | CSS | **Tailwind CSS v3** for maximum UI parity. |
| D5 | Database | Allowed to use the `database` container for verification/tests. Phase 0: `openmu` read-only; writes only in disposable copies. |
| D6 | Phoenix location | **`phoenix/` subdirectory of this repo**, Mix app `:open_mu_web`, modules `OpenMuWeb` / `OpenMuWebWeb`. Rationale: Next.js stays untouched at the root as the parity reference, both apps share `docs/` and `CLAUDE.md`, side-by-side testing against the same DB copy is simple, and later agents have one context. Cutover (Phase 7) can move Phoenix to the root or remove Next.js. |

Deliberate behavior differences already accepted: D1 security fixes (incl. R10: `POST /api/characters/ranking/online` without `playersList` → 400 instead of every character); B2 (Phoenix implements working news pagination and news detail — current Next 16 app is broken there); rendering-only differences listed in Phase 2 results.

## Phase 0 results

### VERIFIED

- PostgreSQL 18.6, DB `openmu`, 48 EF migrations (latest `20260723073950_CascadeDeleteMiniGameRankingEntries`). Dev DB with OpenMU default test data (20 accounts, 76 characters, 0 guilds, 0 news).
- All 8 attribute UUIDs, all 18 class UUIDs, reset map UUIDs, and all 73 `mapEnum` UUIDs exist (`DATABASE.md` §3).
- `CharacterStatus = 32` identifies GM characters in data and yields role `GAME_MASTER`.
- Structures of Account, Character, StatAttribute, ItemStorage, Guild, GuildMember, OpenMuWeb_News; schema drift vs Prisma (4 config tables, 5 new columns with defaults).
- `OpenMuWeb_News` exists and matches README DDL.
- `session.user.id` is undefined at runtime → R3 exploitable; R1, R2, R4 reproduced.
- Game server `/api/status`: `{"state","players","playersList"}` with `Content-Type: text/plain`.
- API behaviors listed in `API.md` (Verification column), incl. game-server-down paths.
- B2 (Next 16 params) broken; B3 base-stat discrepancy; B4 reset keeps Experience/LevelUpPoints.
- Existing hashes `$2a$` verify with node bcrypt; new registrations write `$2b$10$`.

### NOT VERIFIED (needs game client or data that does not exist)

- Rejection of operations while a character is online (no player online).
- Game-client login with a `$2b$` hash created by the website (ASSUMPTION: accepted).
- In-game effect of reset (Experience unchanged) and validity of reset spawn coordinates.
- Guild endpoints with real guild data (no guilds; `Logo` serialization, member `Status` values).
- Concurrency races (R5).
- NextAuth cookie names over HTTPS; signout endpoint.
- Browser-only UI bugs (stale `name` in change password UI, register success toast on error).

### ASSUMPTIONS

- Production uses the same OpenMU schema version / config UUIDs as this dev DB.
- `playersList` is an array of character names.
- No external consumer depends on `/api/*` beyond the website itself.

## Environment state (updated after Phase 2)

- Containers `database`, `openmu-startup`, `nginx-80` are **running** (they were stopped before Phase 0).
- Disposable DB `openmu_phase0` exists in the same cluster and contains test modifications (password change, stats, resets, news, account `p0user`). Safe to drop: `DROP DATABASE openmu_phase0;` (not needed for anything).
- `docs/db/openmu_schema.sql` added (schema only, no data, no secrets).
- Disposable DBs: `open_mu_web_test` (ExUnit, recreated by `phoenix/scripts/setup_test_db.sh`) and `openmu_parity` (Phase 2 parity fixtures; recreate with `TEST_DB=openmu_parity phoenix/scripts/setup_test_db.sh` + fixtures when needed). Phase 4: `openmu_p4_next`, `openmu_p4_phx` (per-app copies for `char_parity.py`; recreate before each run). Phase 5: `openmu_p5_next`, `openmu_p5_phx` (for `admin_parity.py`).
- `next dev` inserted the `nextjs-agent-rules` block into `CLAUDE.md` (kept; it is re-added on every `next dev`).

## Phase 1 results (2026-09-27)

### Delivered

- Toolchain (user space, no sudo; SHA-256 checked): Erlang/OTP **28.5.0.7** (builds.hex.pm, ubuntu-26.04) in `~/.local/beam/otp`, Elixir **1.20.4-otp-28** in `~/.local/beam/elixir`, Hex, rebar, `phx_new` **1.8.15**. PATH line (marked `open-mu-web: BEAM toolchain`) appended to `~/.bashrc`.
- `phoenix/` generated with `mix phx.new phoenix --app open_mu_web --module OpenMuWeb --binary-id --no-mailer`, then adapted:
  - **DB safety**: `ecto.create/drop/reset/setup/load/rollback` aliases raise; `migration_source: "openmu_web_schema_migrations"`; `Phoenix.Ecto.CheckRepoStatus` removed; seeds removed; single migration `20260927000000_ensure_openmu_web_news.exs` (`CREATE TABLE IF NOT EXISTS`, `down` no-op).
  - **Config**: `config/runtime.exs` reads env vars, then `phoenix/.env`, then the root `.env` (dev/test) with the Next.js variable names; `OpenMuWeb.Settings` parses them (empty ⇒ disabled). Dev/test Repo from `DATABASE_URL` / `TEST_DATABASE_URL` (no hard-coded credentials); tests refuse `openmu`. Default port **4001**. Session cookie signed **and encrypted**.
  - **UI**: Tailwind **3.4.17** (`assets/tailwind.config.js` with the Next.js theme), daisyUI removed, core components restyled; `globals.css` rules ported (cursors, `p { white-space: pre }`); `public/img` → `priv/static/images`, favicon copied; Lora 400 latin self-hosted (`priv/static/fonts`, OFL).
  - **Layout** (`Layouts.app` + `SiteComponents`): navbar, secondary nav (Discord link from settings), banner slider (JS in `app.js`), login form / user panel slot, sidebar (server statistics, characters ranking, guilds ranking — empty/offline until Phase 2), footer, flash (top-right, replaces react-toastify).
  - Home page renders the NEWS section header (list in Phase 2).
  - `scripts/setup_test_db.sh`: full copy `openmu` → `open_mu_web_test` via `pg_dump` (source read-only), refuses target `openmu`.
  - `phoenix/AGENTS.md` (project rules header, Tailwind v3 / no daisyUI, `<p>` whitespace rule) and `phoenix/README.md`.

### Verified

- `mix compile --force --warnings-as-errors` passes (warnings only in deps).
- `mix test`: **13 tests, 0 failures** (layout render, static assets, settings parsing, repo/migration source, test DB is a full OpenMU copy, news table columns).
- All six blocked Ecto tasks print "Refusing to run".
- `mix phx.server` against `openmu`: `GET /` 200, CSS/JS/images/font 200; Ecto accepts the shared `postgresql://` URL.
- `openmu` has no `openmu_web_schema_migrations` table; the test DB has it with version `20260927000000`.

### Not verified / known gaps

- Pixel-level visual parity with the Next.js app (no headless browser available; markup/classes were ported 1:1).
- Live reload in dev: needs `inotify-tools` (sudo) — pages work without it.
- `/login`, `/logout`, `/info`, `/ranking`, etc. are not routed yet (Phase 2/3); the login form posts to `/login` (404 until Phase 3).
- Sidebar data, avatars in rankings: Phase 2.

## Phase 2 results (2026-09-27)

### Delivered (`phoenix/`)

- **Ecto schemas** (`lib/open_mu_web/openmu/`): `Account`, `Character`, `StatAttribute`, `ItemStorage`, `Guild`, `GuildMember` (prefix `data`/`guild`, PascalCase `source:`), `News.Article`; `OpenMU.Ids` (attribute ids, GM status 32, GuildMaster 2, class → avatar, 73 map names).
- **Contexts**: `News` (4 per page, newest first, UUID regex like Next), `Rankings` (top characters pivot with `MAX(CASE … ELSE 0)`, top killers, online players), `Guilds` (top, members in Prisma order), `GameServer` (Req, explicit JSON decode of the `text/plain` body, key order kept; `cached_status/0` 5 s ETS cache for the sidebar, `status/0` always fresh), `Float32` (float4 output like node-postgres/JS: `385`, `0.1`).
- **Pages** (controllers, sidebar via `:sidebar` pipeline): `/` news list + `?page=` (working, B2), `/news/:id`, `/info`, `/download` (empty links hidden), `/terms-and-conditions` (text copied verbatim from the Next.js render).
- **Sidebar**: server status (Online/Offline, players), top 10 characters with avatars, top 5 guilds — loaded by plug / LiveView `on_mount` (`OpenMuWebWeb.Sidebar`).
- **`/ranking` LiveView**: tabs Top Characters (50) / Top Killers (30) / Top Guilds (30) / Online Players, tab kept in `?tab=`; guild member popup on hover (colocated hook `.GuildHover`), same toasts as Next ("There was en error!", online-users error).
- **Read-only JSON API** (`:api` pipeline, JSON regardless of Accept): `GET /api/status`, `GET /api/characters/ranking/reset|killers`, `POST /api/characters/ranking/online`, `GET /api/guilds`, `GET /api/guilds/:guild_name` — same URLs, status codes, messages, key order, `Logo` bytes shape, `messasge` typo.
- **Parity tooling**: `phoenix/scripts/parity/api_parity.py`, `phoenix/scripts/parity/page_parity.py` (compare the two apps running on the same DB copy).

### Test / parity results

- `mix precommit` (compile `--warnings-as-errors`, format, tests): **61 tests, 0 failures** (4 runs, random seeds).
- Side-by-side run on DB copy `openmu_parity` (fixtures: 3 guilds with members/logo, 6 news, distinct levels/kills) with a fake OpenMU status server (text/plain, 4 players incl. an unknown name):
  - API: **13/13 cases byte-identical**, except the intended R10 difference.
  - Pages (text incl. exact `<p>` whitespace, images): `/`, `/news/not-a-uuid`, `/info`, `/download`, `/terms-and-conditions` identical; `/?page=1` and `/news/<id>` differ **only because Next.js is broken there (B2)**.
  - Game server down: `/api/status` identical (500 "There was an error"), sidebar offline in both.
- `/ranking` LiveView rows match the Next.js API data (first rows, counts, online order).

### Rendering-only differences (accepted)

- Next.js `<button onClick=router.push>` → Phoenix `<a href>` (Download/Register, news card body, pagination, Return back).
- Sidebar server status is rendered server-side (Next.js fetched it client-side; its first paint was always "offline / 0").
- News date: en-US `M/D/YYYY` of the stored (UTC) value, rendered server-side (Next.js SSR produced the same; the browser re-render used the visitor's locale/timezone).
- Ranking tab is in the URL (`?tab=`) instead of client state only.
- The second banner image is pre-rendered hidden; hidden LiveView connection flashes exist in the HTML.

### Discrepancies recorded (not changed, per D2/D3)

- Guild popup shows a label only for Guild Master (2); OpenMU also has BattleMaster (3) and AssistantMaster (4), shown empty like Next.js.
- OpenMU `Character.State` is `HeroState` (`New = 0`, `Normal = 3`): PK Clear sets `State = 0` ("New"). Relevant for Phase 4; kept as-is (D2).

### Not verified

- Visual/pixel parity (no headless browser); guild popup positioning in a real browser (covered by LiveView `render_hook` tests).
- Behavior with real online players (only the fake status server was used).

## Phase 3 results (2026-09-27)

### Delivered

- `OpenMuWeb.Accounts` (+ `CurrentAccount`, `Registration`): authenticate, GM flag from DB, register (zod-compatible validation and error JSON), change password (R1 fixed), bcrypt via `bcrypt_elixir` (cost 10, `$2b$`; tests use cost 4).
- `OpenMuWebWeb.UserAuth` (plugs + `on_mount` hooks), `SessionController` (`POST /login`, `DELETE /logout`), user panel in the layout (Account, Characters, News for GMs, Sign Out).
- LiveViews `/register` (terms checkbox gate, "The passwords must coincide") and `/account` (login required).
- API: `POST /api/account/register`, `PUT /api/account/changepassword`, `GET /api/auth/session`; `Plugs.LenientParsers` parses `/api/*` bodies like `req.json()`.
- Session cookie encrypted, 30 days; flash messages auto-close after 3 s (react-toastify parity).
- `phoenix/scripts/parity/auth_parity.py`.

### Test / parity results

- `mix precommit`: **95 tests, 0 failures** (3 runs).
- `auth_parity.py`: **0 failures** (register incl. ZodError bodies, logins + session JSON, change password, cross-app logins). Phase 2 `api_parity.py` 13/13 and `page_parity.py` (incl. `/register`, logged-in `/info` and `/account`) still match.

### Deliberate differences (Phase 3)

- R1: change password always targets the logged-in account (body `name` ignored).
- R6: `/account` requires login server-side (Next.js served the page to anyone).
- B1: `/register` shows validation failures as an error toast (text unchanged).
- Roles are read from the DB on each request (Next.js froze them in the JWT at login).
- NextAuth protocol endpoints replaced by `POST /login` / `DELETE /logout`; after login/logout the browser returns to the referring page (Next.js refreshed the current page).
- JSON-valid but non-object bodies on other endpoints may differ in edge details (only register was matched exactly).

### Open questions

- R11: enforce a minimum length (e.g. 8, like register) for new passwords server-side? Kept as Next.js (no rule) until decided.

### Not verified

- Game client login with a website-created `$2b$` hash (no client; source evidence only).
- Real-browser UX (toasts auto-close, Sign Out link with `data-method`) — covered by LiveView/controller tests and HTML parity only.

## Phase 4 results (2026-09-27)

### Delivered

- `OpenMuWeb.Characters`: panel data (pivot, `ORDER BY CharacterSlot`), `add_stats/3`, `pk_clear/2`, `reset/2`, `reset_stats/2`, `enabled?/1`, `ensure_offline/1`; `Ids.stat_ids/0`, `Ids.reset_location/1`, `Ids.leadership_class?/1`; `Character.character_slot`.
- `/characters` LiveView (cards, Reset / Add Stats / Pk Clear / Reset Stats buttons hidden when disabled, Add Stats card with Leadership only for DL/LE, toasts), login required.
- `POST /api/characters/{addstats,pkclear,reset,resetStats}` (`Api.CharacterController`, `OpenMuWebWeb.CharacterMessages`).
- `phoenix/scripts/parity/char_parity.py` (two identical DB copies, same sequence, response + final state diff).

### Test / parity results

- `mix precommit`: **122 tests, 0 failures** (4 runs).
- `char_parity.py` on fresh `openmu_p4_next` / `openmu_p4_phx`: **0 failures** — identical responses for all regular cases (anonymous, own characters, online character, not enough points / zen, not eligible, invalid JSON, unknown character, DL leadership, B5, resets of elf / BM / LE…); final state identical for all 76 characters except the expected R2 / R3 / R4 cases.
- `/characters` page: same cards and texts as Next.js (compared as a set; order now by slot).
- Race test (R5): 8 parallel PK clears with zen for one — Next.js 2 successes and Money −500,000; Phoenix 1 success, Money 500,000.
- API 13/13 and pages still identical; auth parity passes on a shared DB (its cross-app checks need `openmu_parity`).

### Deliberate differences (Phase 4)

- R2: amounts must be integers >= 0 (Next.js accepted negatives and fractions).
- R3: only the logged-in account's characters (Next.js: any character).
- R4: reset location from the DB class (`clasId` ignored).
- R5: no double spending under concurrency.
- `/characters` requires login; cards ordered by `CharacterSlot`; data reloaded after every successful operation.

### Kept on purpose (D2) — follow-ups outside the port

- B3 reset stats base 20 (OpenMU base values differ per class), B4 reset keeps Experience / LevelUpPoints, B5 Leadership points spent without a Leadership row, B14 PK clear sets HeroState.New (0) instead of Normal (3).

### Not verified

- In-game effects of these operations (no game client): reset with unchanged Experience, State 0 after PK clear, reset spawn coordinates.
- A character going online *during* an operation (the online check happens before the transaction, like Next.js).

## Phase 5 results (2026-09-27)

### Delivered

- `OpenMuWeb.News.create_article/3`, `delete_article/2` (GM character of the logged-in account required; author = its first GM character by slot; `creationDate` = UTC now, millisecond precision like Prisma).
- `/admin/news` LiveView (title `maxlength` 200, body `maxlength` 3000, toasts), Game Master only (plug + `on_mount :require_gm`).
- News cards: "Delete" button for Game Masters + confirmation dialog ("Are you sure you want to delete this news?" Yes/No, `assets/js/app.js`); "Yes" → `DELETE /admin/news/:id` (`AdminNewsController`, `require_gm`) → back to the page with "News deleted successfully".
- `POST /api/admin/news`, `DELETE /api/admin/news/:id` (`Api.AdminNewsController`).
- `phoenix/scripts/parity/admin_parity.py`.

### Test / parity results

- `mix precommit`: **136 tests, 0 failures** (4 runs).
- `admin_parity.py` (per-app copies `openmu_p5_next` / `openmu_p5_phx`): **0 failures** — anonymous, GM create (incl. empty strings, text/plain body), missing / non-string fields, invalid JSON, delete existing / already deleted / malformed id, second GM account; news title/body identical.
- Pages: `/admin/news` identical for a GM; `/`, `/info`, `/download`, `/terms-and-conditions`, `/register` identical; API 13/13.

### Deliberate differences (Phase 5)

- R3: a non-GM account can no longer create or delete news (Next.js: 200 for any logged-in user).
- R6: `/admin/news` is refused server-side for anonymous users and non-GMs (Next.js served the page).
- Author: the logged-in account's first GM character by slot (Next.js: first GM character in DB order among all accounts).
- The "Delete" button is part of the server-rendered HTML for Game Masters (Next.js rendered it after hydration).

### Not verified

- The dialog / DELETE flow in a real browser (covered by controller tests and HTML checks; no headless browser).

## Phase 6 results (2026-09-27)

### Delivered

- Inventory of `app/api/**/route.ts` vs the Phoenix router: complete (14 handlers + `/api/auth/session`).
- `Api.FallbackController` (last `/api` route): 405 with empty body for other methods, `OPTIONS` → 204 + `allow`, unknown paths → 404 — allowed methods computed from the router.
- `Plugs.TrailingSlashRedirect` (endpoint): `/path/` → 308 `/path` like Next.js, for pages and API.
- `:api` pipeline answers `Content-Type: application/json` (no charset), like Next.js.
- `phoenix/scripts/parity/http_parity.py` and `run_all.sh` (all stages, DB copies, servers, cleanup).
- `API.md`: compatibility review, HTTP surface table, final list of intentional differences.

### Test / parity results

- `mix precommit`: **141 tests, 0 failures**.
- `run_all.sh` (twice): api 13/13, http **89/89**, pages, auth, char, admin — **all PASS**, no process left running.

### Open questions

- R11 (minimum length of a new password) — still pending.

## Blockers before Phase 7

- None.

## Log

- 2026-09-27 — Repository analysis completed; docs created (`CLAUDE.md`, `docs/*`).
- 2026-09-27 — Decisions D1–D6 recorded. Phase 0 verification against DB, OpenMU game server and Next.js (on DB clone) completed; docs updated with VERIFIED / NOT VERIFIED / ASSUMPTION labels.
- 2026-09-27 — Phase 1 done: BEAM toolchain installed in user space; Phoenix skeleton in `phoenix/` (DB guards, runtime config, Tailwind v3 layout, test DB script, 13 passing tests).
- 2026-09-27 — Phase 2 done: read-only features (schemas, contexts, pages, sidebar, `/ranking` LiveView, read-only `/api/*`), 61 tests, API/page parity checked side by side with Next.js.
- 2026-09-27 — Phase 3 done: authentication (login/logout, session, guards, register, change password, `/api/account/*`, `/api/auth/session`), 95 tests, auth parity 0 failures.
- 2026-09-27 — Phase 4 done: character panel + operations (API + LiveView) with R2–R5 fixes, 122 tests, char parity 0 failures, live race test.
- 2026-09-27 — Phase 5 done: admin news (page, delete dialog, API) with R3/R6 fixes, 136 tests, admin parity 0 failures.
- 2026-09-27 — Phase 6 done: API surface audited and aligned (405/OPTIONS/308/content-type), `run_all.sh` parity runner, 141 tests.
