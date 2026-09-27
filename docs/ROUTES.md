# Page routes (current Next.js app)

All pages share the root layout (see `ARCHITECTURE.md`): nav, banners + login/user panel, sidebar (server status, top 10 characters, top 5 guilds), footer.

| URL | File | Rendering | Auth | Data / actions |
|---|---|---|---|---|
| `/` `?page=N` | `app/page.tsx` → `_components/(sections)/(Section2MainAndRankings)/News.tsx` | Server | No | `OpenMuWeb_News` 4 per page, newest first. "Next page" shown when the page has >3 items; "Prev page" when `page > 0`. Short card: body truncated to 350 chars + `"...  Click to read all."`; click → `/news/:id`. |
| `/news/[id]` | `app/news/[id]/page.tsx` | Server | No | UUID regex `^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$` (case-insensitive) → `findFirst`; otherwise "No News was found!". "Return back" → `/`. |
| `/register` | `app/register/page.tsx` | Client | No | Form username/email/password/repeat + "Accept Terms" checkbox (button disabled until checked). Client check passwords equal → `POST /api/account/register`. |
| `/account` | `app/account/page.tsx` | Client | **No guard** | Change password form → `PUT /api/account/changepassword`. |
| `/characters` | `app/characters/page.tsx` + `CharactersPage.tsx` + `AddStatsCard.tsx` | Server + Client | Session read server-side; without session shows "There are no created characters at the moment" (no redirect) | Lists all characters of the account (accordion). Buttons: Reset (hidden if `NEXT_PUBLIC_ZEN_TO_RESET` empty), Add Stats (always), Pk Clear (hidden if env empty), Reset Stats (hidden if env empty). |
| `/ranking` | `app/ranking/page.tsx` + `(tables)/*` | Client | No | Tabs (state only, not in URL): Top Characters (default), Top Killers, Top Guilds (hover → GuildPopUp), Online Players. |
| `/admin/news` | `app/admin/news/page.tsx` + `AddNews.tsx` | Client | Guard is **client-side only**: `localStorage.role !== "GAME_MASTER"` → redirect `/` | Title (maxLength 200) + body (maxLength 3000) → `POST /api/admin/news`. |
| `/download` | `app/download/page.tsx` | Server (static) | No | Google Drive / Mediafire / Mega buttons (each hidden if env empty); utilities links to dotnet download; static system-requirements table. |
| `/info` | `app/info/page.tsx` | Static | No | Hard-coded server info (Season 6 Episode 3, Exp 500x, drop rates, ...). |
| `/terms-and-conditions` | `app/terms-and-conditions/page.tsx` | Static | No | Template terms text. |
| `/recoverpassword` | — | **Does not exist (404)** | | Linked from LoginForm ("Lost password?"). |

## UI details worth preserving

- Ranking tables:
  - Top Characters: `# | Name (avatar) | Level | Master Level | Resets`.
  - Top Killers: `# | Name (avatar) | Kill Count | Location (map name)`.
  - Top Guilds: `# | Name | Score`, hover row shows popup at mouse position with members `Name | Status` (members list reversed on client).
  - Online Players: `# | Name (avatar) | Map | Position "X, Y"`.
- Sidebar Characters Ranking: `# | Name | Level (+ master level in small red) | Resets`.
- Sidebar Server Statistics: title "OpenMUWeb" (hard-coded), online/offline image depending on `state === "Online"`, "Online Users: N" (0 if unavailable).
- News card: date `creationDate.toLocaleDateString()` + author; GM sees a "Delete" button (from `localStorage.role`) with confirmation dialog.
- Characters card: avatar, name, Resets, Lvl, Master Lvl; Add Stats panel shows Free Points, Strength, Agility, Vitality, Energy (+ Leadership only for DarkLord/LordEmperor).
- After Reset / Reset Stats success: `router.refresh()`. After Add Stats success: local values updated, inputs reset to 0.

## Note on Next 16 params

`app/page.tsx` reads `searchParams.page` and `app/news/[id]/page.tsx` reads `params.id` **synchronously**, but in Next 15+ these are Promises. **VERIFIED broken (2026-09-27)**: Next logs `searchParams is a Promise...` / `params is a Promise...`; `/?page=1` renders the same news as `/`; `/news/<existing id>` renders "No News was found!". Phoenix implements the intended behavior (`?page=N`, detail by UUID) — accepted deliberate difference (see `PORTING_STATUS.md`).

Other VERIFIED page facts: anonymous `/characters` shows "There are no created characters at the moment"; anonymous `/admin/news` returns HTTP 200 (client-side redirect only); `/recoverpassword` → 404.

## Phoenix routes (Phases 2–5)

| URL | Phoenix | Access |
|---|---|---|
| `/`, `/news/:id`, `/info`, `/download`, `/terms-and-conditions` | controllers (`NewsController`, `PageController`) | public |
| `/ranking` | `RankingLive` | public |
| `/register` | `RegisterLive` | public |
| `POST /login`, `DELETE /logout` | `SessionController` | public / logged in |
| `/account` | `AccountLive` | login required |
| `/characters` | `CharactersLive` | login required |
| `/admin/news` | `AdminNewsLive` | Game Master (server-side) |
| `DELETE /admin/news/:id` | `AdminNewsController` (news card "Delete" → confirmation dialog → "Yes") | Game Master |
| `/recoverpassword` | — (404, as in Next.js) | — |

News cards show the "Delete" button to Game Masters in the server-rendered HTML (Next.js added it after hydration from `localStorage.role`).
