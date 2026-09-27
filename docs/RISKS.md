# Risks, security issues and known bugs

Labels: **VERIFIED** = reproduced at runtime on 2026-09-27 (Next.js dev on port 4100 against the disposable clone `openmu_phase0`; production `openmu` untouched). **NOT VERIFIED** = source analysis only. **ASSUMPTION** = reasoned.
Handling in the port: see `PORTING_STATUS.md` → Decisions.

## A. Security issues in the current app

| ID | Severity | Issue | Status | Port handling |
|---|---|---|---|---|
| R1 | Critical | **Change-password account takeover**: new hash written to `LoginName = name` from the body, old password checked against the session account. UI also sends stale `name: ""` on first submit (0 rows, still 200). | **VERIFIED**: `test1` changed `testgm2`'s password, then logged in as `testgm2` (GAME_MASTER). Stale-name UI bug NOT VERIFIED in browser. | **Fixed in Phoenix (Phase 3)**: always the logged-in account; body `name` ignored (verified side by side) |
| R2 | Critical | **Add Stats accepts negative / non-integer / string values**. Negative value lowers a stat and increases `LevelUpPoints`; strings concatenate in `total`. | **VERIFIED**: `str:-10` on `test1Dk` → Strength 28→18, LevelUpPoints 50→60, 200 OK. String input `"1","0",0,0,0` → total became `"10000"` (concatenation) → rejected in that case. | **Fixed in Phoenix (Phase 4)**: each amount must be an integer >= 0 (all zeros still allowed, as before). Also VERIFIED in Next.js: `str: 1.5` was accepted (Strength 29.5, points rounded) |
| R3 | Critical | **`session.user.id` is `undefined`** → `findMany({ AccountId: undefined })` returns all characters → ownership and GM checks bypassed for any logged-in user. | **VERIFIED**: session JSON has no `id`; USER `test1` ran pkclear (Money −1,000,000) and addstats on `testgmDw` (another account) and created news (author = `testgm2Sum`); USER `p0user` deleted news. | Phase 3–4: real account id in the session; **character ownership by `AccountId` (Phase 4, verified side by side)**; GM check for admin news in Phase 5 |
| R4 | High | Reset target map chosen from client-sent `clasId`. | **VERIFIED**: reset of `test400Elf` (High Elf) with Summoner `clasId` moved it to Elbeland (51,226) instead of Noria. | **Fixed (Phase 4)**: location from the DB class; `clasId` ignored (verified: spoofed Summoner id → Lorencia for a Lord Emperor) |
| R5 | Medium | Check-then-act races; resetStats/pkclear decrement `Money` without `>=` guard; reset proceeds even if the Money update matched 0 rows. | **VERIFIED** (Phase 4): 8 parallel PK clears with zen for one → Next.js 2 successes, Money −500,000 | **Fixed (Phase 4)**: transaction with `FOR UPDATE` on character + inventory, checks inside → 1 success, Money 500,000 |
| R6 | Medium | `/admin/news` and `/account` have no server guard; GM UI relies on `localStorage.role`; role in JWT stale until re-login. | **VERIFIED**: anonymous GET `/admin/news` → 200 (client redirect only) | Phase 3: `/account` guarded server-side (plug + LiveView hook), GM flag from DB per request; `require_gm` ready for `/admin/news` (Phase 5) |
| R7 | Medium | `.env` tracked in git (contains `DATABASE_URL`, `NEXTAUTH_SECRET`). | VERIFIED (`git ls-files .env`) | Rotate secrets; Phoenix uses env/runtime.exs, no committed secrets |
| R8 | Low | No rate limiting on login/register; no server validation of news title/body; email uniqueness only in app code (no DB index). | NOT VERIFIED at runtime (source + `\d` shows no index — VERIFIED) | Add validation; rate limiting optional |
| R10 | Medium | `POST /api/characters/ranking/online` without `playersList` returns **every character with map and position** (Prisma ignores `in: undefined`), including offline players. | **VERIFIED** (Phase 2: 76 characters returned) | Fixed in Phoenix (D1 principle): missing / non-list / non-string list → 400 `There was a problem try again later` |
| R11 | Low | Change password has no server-side rule for the new password (the Next.js form only had `minlength=8`; the API accepts e.g. 1 character). | VERIFIED (source) | Kept for parity in Phase 3 — **open question** (see PORTING_STATUS) |
| R12 | Low | Sessions are stateless cookies (NextAuth JWT before, signed+encrypted Phoenix cookie now): logout / password change do not revoke copies of an old cookie until it expires (30 days). | Design | Kept (same as before); a server-side token table would need a new website table |
| R9 | High (deployment) | The DB contains OpenMU **default test accounts with password = login name**, including GM accounts `testgm` / `testgm2`. | VERIFIED on dev DB | Must be removed/changed on any public deployment (outside website scope) |

## B. Functional bugs / oddities

| ID | Issue | Status |
|---|---|---|
| B1 | Register: any exception (incl. validation) → 500 without `user`; client shows a *success* toast "Something went wrong!". | API part VERIFIED (500 + ZodError body); toast NOT VERIFIED in browser. **Phoenix**: API identical; `/register` page shows it as an error toast |
| B2 | Next 16: `searchParams.page` (`/`) and `params.id` (`/news/[id]`) read synchronously. | **VERIFIED broken**: Next logs `searchParams is a Promise...` / `params is a Promise...`; `/?page=1` shows the same 4 news as `/`; `/news/<existing id>` shows "No News was found!". |
| B3 | Reset Stats sets every stat to 20; OpenMU base values are per class. | **VERIFIED discrepancy**: DB base values differ (e.g. DW 18/18/15/30, DK 28/20/25/10, RF 32/27/25/20). Test: DW `test1Dw` 18/18/15/30 → 20/20/20/20, +1 point. Kept by D2; separate follow-up. |
| B4 | Reset leaves `Experience` and `LevelUpPoints` unchanged. | **VERIFIED** (`test400Elf`: Level 400→1, Resets 0→1, Experience 3822148080 unchanged, LevelUpPoints unchanged). In-game effect NOT VERIFIED. Kept by D2. |
| B5 | Add Stats: missing stat row (e.g. Leadership on non-DL) → points deducted, no stat increase. | **VERIFIED** (Phase 4: DK `lead: 5` → −6 points, +1 Str only). Kept in Phoenix (D2), identical in the parity run |
| B6 | Inconsistent status codes: forbidden/no session → 500; `/api/status` success → 201; guild not found → 400 with key `messasge`. | VERIFIED |
| B7 | `/api/guilds` returns `Logo` bytea as a byte-indexed JSON object. | **VERIFIED** (Phase 2, parity DB): `{"0":1,"1":2,"2":255}`; reproduced by Phoenix |
| B8 | Two pivot variants: ranking `ELSE 0`; characters panel no `ELSE` (NULL). | Source; keep each |
| B9 | `/recoverpassword` linked but missing. | VERIFIED 404 |
| B10 | Server APIs self-call `${NEXT_PUBLIC_URL}/api/status`. | VERIFIED behavior (works when URL correct) |
| B11 | News `author` = GM character name (first GM char found among all characters because of R3). | VERIFIED |
| B12 | Game server `/api/status` responds with `Content-Type: text/plain` although body is JSON. | VERIFIED |
| B13 | `prisma/schema.prisma` is out of date vs DB (4 config tables, 5 columns missing). | VERIFIED; harmless for current app |
| B14 | `Character.State` is OpenMU `HeroState` (`New=0 … Normal=3`); PK Clear sets `State = 0` ("New"), not "Normal". | VERIFIED from OpenMU source (`Character.cs`); in-game effect NOT VERIFIED. Kept (D2), revisit separately |
| B15 | Guild popup labels only status 2 (Guild Master); OpenMU `GuildPosition` also has BattleMaster (3) and AssistantMaster (4), shown empty. | VERIFIED from OpenMU source (`GuildPosition.cs`). Kept for parity |

## C. Porting risks

| ID | Risk | Mitigation |
|---|---|---|
| P1 | Destructive operations on the shared OpenMU DB. | No ecto create/drop/reset aliases; separate `migration_source`; only `CREATE TABLE IF NOT EXISTS` for news; tests on a disposable full copy. |
| P2 | Hard-coded UUIDs. | VERIFIED all attribute/class/map UUIDs exist (see `DATABASE.md`). Remaining risk: a different OpenMU version/config in production (ASSUMPTION same). |
| P3 | NextAuth sessions cannot be migrated. | Users re-login after cutover. |
| P4 | bcrypt compatibility with the game server for `$2b$` hashes. | Website already writes `$2b$`; game-client login NOT VERIFIED → test in Phase 3. |
| P5 | Game server status content type is `text/plain`. | Done (Phase 2): `OpenMuWeb.GameServer` decodes explicitly, keeps key order. |
| P6 | PascalCase identifiers need `source:` everywhere. | Central schemas `OpenMuWeb.OpenMU.*`. |
| P7 | Fixing R1–R6 and B2 changes observable behavior. | Recorded as deliberate differences (D1, B2 note in PORTING_STATUS). |
| P8 | Phoenix CSRF on `:browser` vs JSON API clients. | Separate `:api` pipeline (D3 keeps APIs). |
| P9 | Tailwind v3 arbitrary-value classes. | D4: keep Tailwind v3. |
| P10 | Global `p { white-space: pre }`. | Port CSS as-is. |
| P11 | Test DB needs `config` reference rows (FKs). | Use full DB copy for tests, not schema-only (see `DATABASE.md` §5). |
| P12 | Parity tests on ranking with ties may differ in order. | Compare sets or add deterministic tiebreak only where current order is deterministic. |
| P13 | Elixir/Erlang toolchain not installed in the WSL environment. | Install before Phase 1 (blocker). |
