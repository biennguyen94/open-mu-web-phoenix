# Authentication & authorization

Labels: **VERIFIED** = observed at runtime on 2026-09-27 (Next.js dev server on port 4100 against the disposable clone `openmu_phase0`, test accounts). **NOT VERIFIED** / **ASSUMPTION** as marked.

## Current (NextAuth v4) — `lib/auth.ts`

Config: `adapter: PrismaAdapter(prisma)` (effectively unused: Credentials + JWT; no NextAuth tables in DB), `session.strategy: "jwt"`, `secret: NEXTAUTH_SECRET`, `pages.signIn: ""`, single `CredentialsProvider` (`username`, `password`).

### Login flow

```text
LoginForm (client) → signIn("credentials", { username, password, redirect: false })
  → NextAuth: GET /api/auth/csrf, POST /api/auth/callback/credentials
  → authorize(credentials):
       missing username/password → null
       prisma.account.findUnique({ LoginName: username })     exact match, case-sensitive (VERIFIED: "TESTGM" → 401)
       bcrypt.compare(password, PasswordHash)                  wrong password → 401 (VERIFIED)
       prisma.character.findMany({ AccountId: account.Id })
       role = any character CharacterStatus === 32 ? "GAME_MASTER" : "USER"   (VERIFIED: testgm → GAME_MASTER, test1 → USER)
       return { id: Account.Id, username: LoginName, email: EMail, role }
  → jwt callback (sign-in): token = { ...token, username, id, role }
  → session callback: session.user = { ...session.user, username: token.username, role: token.role }
  → client: error → toast " Invalid Username or Password"; ok → router.refresh() + toast "Welcome back <username>"
  → Section1 (RSC) getServerSession → UserPanel(role) → localStorage.setItem("role", role)
```

Client form: `minLength=4` on inputs (HTML only).

### Session — VERIFIED

- `GET /api/auth/session` returns exactly:
  `{"user":{"email":"","username":"testgm","role":"GAME_MASTER"},"expires":"<now + 30 days>"}`
  → **no `id`, no `name`**. `session.user.id` is **`undefined`** at runtime.
- Cookies over HTTP: `next-auth.session-token`, `next-auth.csrf-token`, `next-auth.callback-url` (all HttpOnly). Over HTTPS NextAuth uses `__Secure-`/`__Host-` prefixes (NOT VERIFIED here).
- Expiry 30 days (NextAuth default; VERIFIED from `expires`).
- Role is computed once at login and stored in the JWT (not refreshed until re-login).
- Consequence (VERIFIED, see `RISKS.md` R3): server code using `session.user.id` runs `findMany({ where: { AccountId: undefined } })`, which Prisma treats as no filter → returns **all characters** → ownership and GM checks are bypassed for any logged-in user.

### Logout

`UserPanel.onSignOut`: `localStorage.removeItem("role")` then `signOut()` (NextAuth POST `/api/auth/signout`).

### Password hashing — VERIFIED

- Existing OpenMU accounts: `$2a$` bcrypt hashes; node `bcrypt.compare` verifies them (login works).
- Website register / change password: `bcrypt.hash(pw, 10)` → `$2b$10$...`; login with such an account works on the website.
- Game-server login with a `$2b$` hash created by the website: **NOT VERIFIED** (no game client available). ASSUMPTION: OpenMU (BCrypt.Net) accepts `$2b$`.
- OpenMU default test accounts in the dev DB use password = login name (e.g. `test1`, `testgm`). They are test data only.

### Authorization matrix (current)

| Resource | Server-side check | Client-side check | Runtime result (VERIFIED) |
|---|---|---|---|
| `/characters` page | `getServerSession`; query by `session.user.username` | — | Correct: shows only the account's characters; anonymous → "There are no created characters at the moment" |
| `/account` page | none | none | — |
| `/admin/news` page | none | `localStorage.role === "GAME_MASTER"` else redirect | Anonymous GET → HTTP 200 (page served, client-side redirect) |
| Character APIs | session + `name` ∈ characters of `session.user.id` | — | **Bypassed**: USER `test1` performed pkclear and addstats on `testgmDw` |
| Change password API | session username for old-password check; update uses body `name` | — | **Bypassed**: `test1` changed `testgm2` password |
| Admin news APIs | session + characters of `session.user.id` include status 32 | Delete button via `localStorage.role` | **Bypassed**: USER `test1`/`p0user` created and deleted news (author became `testgm2Sum`, a GM of another account) |
| No session | — | — | Character/admin APIs → 500 "You can't do this!" |

## Phoenix implementation (Phase 3, 2026-09-27) — D1: R1 fixed, R3/R6 groundwork

- `Plug.Session` cookie store (signed + encrypted) storing `account_id` (+ login name); renew session on login, drop on logout.
- `fetch_current_account` plug loads the Account from DB each request; `require_authenticated` / `require_gm` plugs + LiveView `on_mount` hooks.
- Ownership: character must have `AccountId == current_account.id` (fixes R3). GM = account has a character with `CharacterStatus == 32`, checked from DB per protected request; admin pages guarded server-side.
- Change password updates **the current account only** (fixes R1); `name` in the JSON body is ignored (decided in Phase 3).
- `Bcrypt.verify_pass/2` (accepts `$2a$` and `$2b$`), `Bcrypt.hash_pwd_salt(pw, log_rounds: 10)`; `Bcrypt.no_user_verify/0` for unknown users.
- Login remains exact, case-sensitive `LoginName` match.
- Existing NextAuth sessions cannot be migrated → all users re-login after cutover.
- Verified in Phase 3: legacy `$2a$` accounts log in to Phoenix (see below). Game-client login with Phoenix-created accounts: NOT VERIFIED (no client).

### Implemented (Phase 3)

| Piece | Phoenix |
|---|---|
| Login | `POST /login` (`SessionController.create`, layout form, CSRF token) → `Accounts.authenticate/2` (exact `LoginName`, `Bcrypt.verify_pass`, `Bcrypt.no_user_verify` for unknown users) → session renewed, `account_id` stored → flash "Welcome back <username>" / " Invalid Username or Password" → redirect to the referring page (same-site paths only) |
| Logout | `DELETE /logout` (user panel "Sign Out") → session dropped (+ LiveView sockets disconnected) → back to the referring page |
| Session | Cookie `_open_mu_web_key`, signed **and encrypted**, SameSite=Lax, `max_age` 30 days; contains only `account_id` |
| Current account | `UserAuth.fetch_current_account` (browser + api pipelines) / `on_mount :mount_current_account`: `%CurrentAccount{id, login_name, email, gm?}` loaded from DB each request; stale ids are dropped |
| Guards | `require_authenticated` / `require_gm` plugs and `on_mount` hooks → redirect `/` with flash "You can't do this!" (`/account`, `/characters` use it; `/admin/news` gets `require_gm` in Phase 5) |
| Register | `/register` LiveView and `POST /api/account/register` share `Accounts.register/1`; validation reproduces the zod schema **and its error JSON** (`Accounts.Registration`) |
| Change password | `/account` LiveView and `PUT /api/account/changepassword` share `Accounts.change_password/4`; always the logged-in account (R1) |
| Session JSON | `GET /api/auth/session` — same shape as NextAuth (`{}` when anonymous). The NextAuth protocol endpoints (`/api/auth/csrf`, `/callback/credentials`, `/signout`, `/providers`) are not ported: replaced by `/login` and `/logout` |
| Body parsing | `/api/*` bodies are parsed like `req.json()` (any Content-Type; empty/malformed → the route's own error JSON) — `Plugs.LenientParsers` |

### Verification (Phase 3)

- VERIFIED side by side (`phoenix/scripts/parity/auth_parity.py`, 33 checks, 0 failures): register responses incl. byte-identical ZodError bodies (types, arrays, emoji, emails, empty/invalid/non-object JSON), login results and session JSON for OpenMU (`$2a$`) accounts, GM and wrong/case-changed credentials, change-password messages (logged in and anonymous), success paths.
- VERIFIED cross-app: an account created (and a password changed) by Phoenix logs in on Next.js and vice versa (bcrypt_elixir ⇄ node bcrypt, both `$2b$`).
- VERIFIED R1 fix: with `name` of another account, Next.js changed that account's hash; Phoenix changed only the logged-in account.
- Game client login with a `$2b$` hash: **NOT VERIFIED** (no client). Source evidence: OpenMU verifies with `BCrypt.Net.BCrypt.Verify` (BCrypt.Net-Next 4.0.3, supports `$2a$`/`$2b$`); the Next.js app already wrote `$2b$` hashes.
