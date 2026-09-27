# API endpoints (current Next.js app)

All handlers are in `app/api/**/route.ts`. All bodies are JSON. Unless noted, errors are `{ "message": string }`.
"Ownership check" = session exists AND `name` is among `character.findMany({ AccountId: session.user.id })` names (see `AUTH.md` / `RISKS.md` about `session.user.id`).
"Online check" = server fetches `${NEXT_PUBLIC_URL}/api/status`; if `playersList` includes `name` → 400 `"Disconnect from your account!"`; if the fetch is not ok → 500 `"Couldn't reach the server, try again later"`.

## Summary

Verification column: runtime test on 2026-09-27 (Next.js dev on port 4100, disposable DB clone `openmu_phase0`, OpenMU game server running). **VERIFIED** = observed; **partial** = only some paths observed; **NOT VERIFIED** = not exercised.

| Method | URL | Auth | Tables | Purpose | Verification |
|---|---|---|---|---|---|
| GET, POST | `/api/auth/[...nextauth]` | — | data.Account, data.Character | NextAuth endpoints (csrf, callback/credentials, session, signout, providers) | VERIFIED (csrf, callback ok/401, session); signout NOT VERIFIED |
| POST | `/api/account/register` | No | data.Account | Register | VERIFIED 201, 409 ×2, 500 |
| PUT | `/api/account/changepassword` | Session (flawed) | data.Account | Change password | VERIFIED (incl. R1 exploit) |
| POST | `/api/characters/addstats` | Ownership (bypassed, R3) | Character, StatAttribute | Add stat points | VERIFIED 200, 400, 500; online-reject NOT VERIFIED |
| POST | `/api/characters/reset` | Ownership (bypassed, R3) | Character, StatAttribute, ItemStorage | Reset character | VERIFIED 200, 400 ineligible |
| POST | `/api/characters/resetStats` | Ownership (bypassed, R3) | Character, StatAttribute, ItemStorage | Reset stat points | VERIFIED 200 |
| POST | `/api/characters/pkclear` | Ownership (bypassed, R3) | Character, ItemStorage | Clear PK status | VERIFIED 200, 500 no session, 500 server down |
| GET | `/api/characters/ranking/reset` | No | StatAttribute ⋈ Character | Top 50 characters | VERIFIED |
| GET | `/api/characters/ranking/killers` | No | Character | Top 30 killers | VERIFIED |
| POST | `/api/characters/ranking/online` | No | Character | Details of online players | partial (empty result only; no player online) |
| GET | `/api/guilds` | No | guild.Guild | Top 30 guilds | partial (`[]`; no guilds in DB) |
| GET | `/api/guilds/[guildName]` | No | GuildMember ⋈ Character ⋈ Guild | Guild members | partial (400 path only) |
| POST | `/api/admin/news` | GM (bypassed, R3) | Character, OpenMuWeb_News | Create news | VERIFIED 200 |
| DELETE | `/api/admin/news/[id]` | GM (bypassed, R3) | Character, OpenMuWeb_News | Delete news | VERIFIED 200, 400 not found, 500 no session |
| GET | `/api/status` | No | — (HTTP to game server) | Proxy game server status | VERIFIED 201, 500 when game server down |

## Details

### `POST /api/account/register`
- Input: `{ LoginName, EMail, Password, RepeatPassword }`.
- Zod: LoginName 4–10 chars; EMail 5–30 chars + email format; Password 8–20; RepeatPassword min 8; Password === RepeatPassword.
- `findFirst({EMail})` → 409 `{user: null, message: "Email already in use!"}`.
- `findFirst({LoginName})` → 409 `{user: null, message: "Username already in use!"}`.
- Insert Account: `Id = randomUUID()`, `LoginName`, `EMail`, `PasswordHash = bcrypt.hash(Password, 10)`, `SecurityCode ""`, `State 0`, `TimeZone 0`, `VaultPassword ""`, `IsVaultExtended false`, `RegistrationDate new Date()`. No vault, no characters.
- 201 `{user: <LoginName>, message: "User created succesfully!"}`.
- Any exception (incl. Zod error) → 500 `{message: "Something went wrong!", error}` (no `user` key). VERIFIED: `error` is the serialized ZodError (`{"name":"ZodError","message":"[...issues JSON...]"}`).
- VERIFIED insert result: `PasswordHash` `$2b$10$...`, `SecurityCode ''`, `State 0`, `TimeZone 0`, `VaultId NULL`, DB defaults `IsTemplate false`, `LanguageIsoCode 'en'`, `IsBot false`.
- Client: toast error only if `response.user === null`, otherwise toast success (so 500 shows a *success* toast with "Something went wrong!").

### `PUT /api/account/changepassword`
- Input: `{ name, oldPassword, newPassword, repeatNewPassword }`.
- If session exists but `session.user.username` falsy → 400 "You can't do this!". If no session, continues (then fails at DB lookup → 400).
- `oldPassword === newPassword` → 400 "New password and old password are the same!".
- `newPassword !== repeatNewPassword` → 400 "New password and Reapeat password should match!".
- `account = findUnique({LoginName: session.user.username})`; `bcrypt.compare(oldPassword, account.PasswordHash)` false → 400 "The old password you inserted isn't correct!".
- `account.updateMany({ where: { LoginName: name /* from body */ }, data: { PasswordHash: bcrypt(newPassword, 10) } })`.
- 200 "Password changes successfully" (even if 0 rows updated). Exception → 400 "There was a problem try again later".
- **Security issue** (VERIFIED): logged in as `test1`, body `{"name":"testgm2","oldPassword":"test1",...}` → 200 and `testgm2` could then log in with the new password. See `RISKS.md` R1.

### `POST /api/characters/addstats`
- Input: `{ name, str, agi, vit, ene, lead }`. See `FEATURES.md` → Add Stats.
- No session / not owner → **500** "You can't do this!". Online check. `LevelUpPoints < total` → 400 "You don't have enough points!".
- 200 "Character points added succesfuly". Exception → 400 "There was a problem try again later".

### `POST /api/characters/reset`
- Env `NEXT_PUBLIC_ZEN_TO_RESET` empty → 400 "Function disabled".
- Input: `{ name, clasId }`. Not owner → 400 "You can't do this! Try to Login again."; no session → 400 "You can't do this!". Online check.
- Not eligible → 400 `"You aren't lvl " + LVL_TO_RESET + " or you are at maximum reset " + MAX_RESET`. Not enough zen → 400 `"You don't have enough zen: " + zen`.
- 200 "Character reseted successfully!". Exception → 400 "There was a problem while resetting your character".

### `POST /api/characters/resetStats`
- Env `NEXT_PUBLIC_ZEN_TO_RESET_STATS` empty → 400 "Function disabled".
- Input: `{ name, clasId }` (`clasId` unused). No session / not owner → 400 "You can't do this!". Online check. Not enough zen → 400 "You don't have enough zen: " + zen.
- 200 "Points were reseted succesffuly". Exception → 400 "There was a problem while reseting the points".

### `POST /api/characters/pkclear`
- Env `NEXT_PUBLIC_ZEN_TO_PKCLEAR` empty → 400 "Function disabled".
- Input: `{ name }`. No session / not owner → **500** "You can't do this!". Online check. Not enough zen → 400.
- 200 "PkClear successfully". Exception → 400 "There was a problem try again later".

### `GET /api/characters/ranking/reset`
- Output: `[{ CharacterId, Name, CharacterClassId, resets, lvl, masterlvl }]` (top 50, query in `DATABASE.md`). Error → 400.

### `GET /api/characters/ranking/killers`
- Output: `[{ Id, CharacterClassId, CurrentMapId, Name, PlayerKillCount }]` (top 30). Error → 400.

### `POST /api/characters/ranking/online`
- Input: the `ServerStatus` object `{ state, players, playersList }` (client forwards the `/api/status` response).
- Output: `[]` or `[{ Name, CurrentMapId, CharacterClassId, PositionX, PositionY }]` for `Name IN playersList`. Error → 400.

### `GET /api/guilds`
- Output: full `Guild` rows (`Id, HostilityId, AllianceGuildId, Name, Logo, Score, Notice`), top 30 by `Score` desc. `Logo` is `bytea` (serialized by JSON as a byte-indexed object). No try/catch.

### `GET /api/guilds/[guildName]`
- Output: `[{ Name, guildStatus }]`. Empty → 400 `{ "messasge": "Guild wasn't found" }` (typo in key is real). Exception → 400 `{ message: "Guild wasn't found" }`.

### `POST /api/admin/news`
- Input: `{ title, body }` (client sends it **without** a Content-Type header; no server-side validation).
- No session → **500** "You can't do this!". Account has no character with `CharacterStatus === 32` → **500** "You can't do this!".
- Insert `{ author: <first GM character's Name>, title, body }` (id/creationDate by defaults).
- 200 "News added successfully". Exception → 400 "There was a problem try again later".

### `DELETE /api/admin/news/[id]`
- Same GM check (500 on failure). `openMuWeb_News.delete({ id })`. 200 "News deleted successfully". Exception (incl. not found) → 400.

### `GET /api/status`
- `fetch(${GAMESERVER_URL}/api/status, { next: { revalidate: 0 } })`.
- OK → **201** `application/json` with the game server JSON unchanged.
- Game server response (VERIFIED, OpenMU admin via `http://localhost/api/status` (nginx) and `http://localhost:8081/api/status`): HTTP 200, body `{"state":"Online","players":0,"playersList":[]}`, **`Content-Type: text/plain; charset=utf-8`** → Phoenix client must decode JSON explicitly (Req will not auto-decode).
- `playersList` element type with players online is NOT VERIFIED (ASSUMPTION: array of character name strings, as used by `includes(name)` and `Name IN (...)`).
- Game server unreachable → exception → 500 "There was an error" (VERIFIED by stopping nginx). Non-2xx → 500 "Couldn't connect to the gameserver" (NOT VERIFIED).
- Character APIs when the game server is down → 500 "Couldn't reach the server, try again later" (VERIFIED on pkclear).

## Phoenix implementation status

| Endpoint | Phoenix (Phase) | Parity |
|---|---|---|
| `GET /api/status` | `Api.StatusController` (2) | byte-identical (201, 500 paths) |
| `GET /api/characters/ranking/reset` | `Api.RankingController.reset` (2) | byte-identical |
| `GET /api/characters/ranking/killers` | `Api.RankingController.killers` (2) | byte-identical |
| `POST /api/characters/ranking/online` | `Api.RankingController.online` (2) | byte-identical; **R10** fixed: missing `playersList` → 400 |
| `GET /api/guilds` | `Api.GuildController.index` (2) | byte-identical (incl. `Logo` bytes object) |
| `GET /api/guilds/[guildName]` | `Api.GuildController.show` (2) | byte-identical (incl. `messasge` key) |
| `POST /api/account/register` | `Api.AccountController.register` (3) | byte-identical (201/409/500 incl. ZodError, invalid/empty/non-object JSON, text/plain body) |
| `PUT /api/account/changepassword` | `Api.AccountController.change_password` (3) | identical messages/status; **R1** fixed (logged-in account only) |
| `GET /api/auth/session` | `Api.AuthController.session` (3) | same JSON shape (`expires` = now + 30 days) |
| other `/api/auth/*` (NextAuth protocol) | not ported — `POST /login`, `DELETE /logout` | deliberate |
| character / admin endpoints | Phase 4 / 5 | — |

VERIFIED from OpenMU source (`src/Web/AdminPanel/API/ServerController.cs`): `playersList` is the list of player (character) names and `state` is always `"Online"` when the admin panel answers; the JSON is returned via `Ok(string)`, hence `text/plain`.

Next.js edge cases observed in Phase 2 (parity DB): `playersList` with non-strings or a string → 400; body without `playersList` → 200 with all 76 characters (R10).

## Porting note (decision D3)

All `/api/*` JSON endpoints are **kept** in Phoenix during the port (same URLs, payload shapes, messages and status codes) for compatibility and parity testing. Exceptions by decision D1: authorization fixes (R1–R3) change who is allowed, not the response format. LiveViews call the same context functions as the API controllers. `/api/auth/[...nextauth]` is NextAuth-specific; its Phoenix equivalent is the session login/logout (contract to define in Phase 3).
