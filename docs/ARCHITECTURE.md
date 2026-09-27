# Architecture

> Section 1 is from source code; runtime facts are verified in `DATABASE.md`, `API.md`, `AUTH.md` (labels VERIFIED / NOT VERIFIED / ASSUMPTION). Sections 2–3 are the target design (decisions D1–D6 in `PORTING_STATUS.md`).

## 1. Current architecture (Next.js)

```text
Browser
 ├─ React Client Components ── fetch(`${NEXT_PUBLIC_URL}/api/...`) ──┐
 └─ React Server Components ── Prisma directly ───────────────────────┤
                                                                      ▼
Next.js 16 App Router (port 4000)                         PostgreSQL (existing OpenMU DB)
 ├─ app/api/* route handlers ── Prisma 7 + @prisma/adapter-pg ──► schemas: data, guild
 ├─ NextAuth v4 (Credentials provider, JWT session)
 └─ GET /api/status ── fetch ──► ${GAMESERVER_URL}/api/status   (OpenMU admin API)
```

Facts:

- No `middleware.ts`. No server actions. All writes go through JSON route handlers under `app/api/`.
- `lib/prisma.ts`: singleton `PrismaClient` with `PrismaPg` adapter using `DATABASE_URL`.
- `lib/auth.ts`: `authOptions` (see `AUTH.md`).
- `prisma.config.ts`: schema `prisma/schema.prisma`, migrations path `prisma/migrations` (directory does **not** exist; DB is not managed by Prisma Migrate).
- The server-side character APIs call **their own app** over HTTP (`${NEXT_PUBLIC_URL}/api/status`) to check whether a character is online.

### Root layout (`app/layout.tsx`) — rendered on every page

```text
<body>  (font: Lora via next/font/google, bg /img/bg-header.jpg)
  Navbar            HOME /, INFO /info, RANKING /ranking, DOWNLOAD /download
  SecondaryNav      buttons → /download, /register; Discord link (NEXT_PUBLIC_DISCORD_LINK)
  Section1 (RSC)    Banners (client slider, 2 images, auto 5 s) + LoginForm | UserPanel(role)
  [ page content ]  +  sidebar:
                       ServerStatistics (client, fetch /api/status)
                       TopPlayers  (RSC, raw SQL top 10)
                       TopGuilds   (RSC, prisma top 5)
  Footer            © OpenMUWeb, Terms link, Contact (Discord user link)
  ToastContainer    react-toastify, top-right, autoClose 3000
```

So every page request runs the top-10 character query + top-5 guild query server-side, and the browser fetches `/api/status`.

### Source layout

```text
app/
  _components/   Navbar, SecondaryNav, Footer, GuildPopUp, News, NewsCard, ChangePageButton,
                 DeleteConfirmationDialog, ReturnToHomeButton, ServerStatistics, TopPlayers,
                 TopGuilds, Banners, LoginForm, Section1, UserPanel
  _models/       TS interfaces (CharacterRanking, CharacterEdit, CharacterOnline, GuildMember,
                 CharacterKillers, News, NewsComplete, Login, RegisterAccount, ServerStatus)
  _utils/        characterAvatarReturn.ts (class UUID → avatar), mapEnum.ts (map UUID → name)
  api/           route handlers (see API.md)
  <pages>        see ROUTES.md
lib/             auth.ts, prisma.ts
prisma/          schema.prisma (introspected OpenMU schema + OpenMuWeb_News)
public/img/      all static images (avatars, icons, banners, cursors, backgrounds)
types/           next-auth.d.ts (User: username,id,role; Session.user.username)
```

### Styling

- Tailwind 3 (`tailwind.config.ts`) custom colors: `primary #105D71`, `secondary #A5F1F1`, `tertiary #A5EFFA`, `oceanic #EAEFF3`.
- `app/globals.css`: `.remove-arrow` (hide number spinners); custom cursors `/img/cursor/Cursor.png` (body) and `/img/cursor/CursorGet.png` (button/a/.news-body hover); **`p { white-space: pre; }`** (affects all paragraphs, incl. news body line breaks).
- Fixed widths: main container `w-[1250px]`, footer `w-[1400px]` (not responsive).

### Environment variables (names only)

| Variable | Used in | Meaning |
|---|---|---|
| `DATABASE_URL` | lib/prisma.ts, prisma.config.ts | Postgres connection |
| `NEXTAUTH_SECRET` | lib/auth.ts | JWT encryption secret |
| `NEXTAUTH_URL` | NextAuth | Canonical URL |
| `NEXT_PUBLIC_URL` | all client fetches + server self-fetch of `/api/status` | Base URL of this site |
| `GAMESERVER_URL` | app/api/status | OpenMU admin base URL (`/api/status` appended) |
| `NEXT_PUBLIC_GOODLE_DRIVE_LINK` (sic), `NEXT_PUBLIC_MEDIAFIRE_LINK`, `NEXT_PUBLIC_MEGA_LINK` | download page | Hidden when empty |
| `NEXT_PUBLIC_DISCORD_LINK` | SecondaryNav | Discord invite |
| `NEXT_PUBLIC_ZEN_TO_RESET` | reset API + characters UI | Empty ⇒ reset disabled |
| `LVL_TO_RESET` | reset API | Minimum level (compared with `>=`) |
| `MAX_RESET` | reset API | Resets must be `<` this |
| `NEXT_PUBLIC_ZEN_TO_PKCLEAR` | pkclear API + UI | Empty ⇒ disabled |
| `NEXT_PUBLIC_ZEN_TO_RESET_STATS` | resetStats API + UI | Empty ⇒ disabled |

## 2. Target architecture (Phoenix) — location `phoenix/` (decision D6); implemented so far: Phase 1–2 (see `PORTING_STATUS.md`)

```text
phoenix/                               (Mix app :open_mu_web)
├── lib/open_mu_web/                  # core, no web deps
│   ├── repo.ex
│   ├── openmu/                       # Ecto schemas mapped onto existing OpenMU tables
│   │   ├── account.ex  character.ex  stat_attribute.ex  item_storage.ex
│   │   ├── guild.ex    guild_member.ex
│   │   └── ids.ex                    # hard-coded UUIDs (attributes, classes, maps), GM status 32
│   ├── accounts.ex                   # register, authenticate, change_password, gm?
│   ├── characters.ex                 # list_for_account, add_stats, reset, reset_stats, pk_clear
│   ├── rankings.ex                   # top_characters(limit), top_killers, online_players
│   ├── guilds.ex                     # top(limit), members(name)
│   ├── news.ex + news/article.ex     # data."OpenMuWeb_News"
│   ├── game_server.ex                # Req client → GAMESERVER_URL/api/status (+ short cache)
│   └── settings.ex                   # runtime config (zen costs, reset rules, download links) — DONE (Phase 1)
└── lib/open_mu_web_web/
    ├── router.ex                     # pipelines :browser, :api; scopes require_auth / require_gm
    ├── user_auth.ex                  # plugs + LiveView on_mount hooks
    ├── controllers/                  # PageController (info/download/terms), SessionController (login/logout),
    │                                 # NewsController (home, show), Api.* (all /api/* endpoints kept, D3)
    ├── live/                         # RegisterLive, AccountLive, CharactersLive, RankingLive, Admin.NewsLive
    └── components/                   # layouts.ex + site_components.ex (chrome, sidebar) — DONE (Phase 1);
                                      # core_components (restyled, no daisyUI), ranking tables, guild popup
```

Design notes:

- **Controllers / dead views**: Home (news list), news detail, Info, Download, Terms.
- **LiveView**: Characters panel (events call `Characters.*`, `put_flash` replaces toasts), Rankings (tabs via `handle_params` `?tab=`), Register, Account (change password), Admin news.
- **Login** must set the session cookie → controller `POST` (phx.gen.auth style; LiveView form with `phx-trigger-action` is fine).
- **Sidebar**: layout function component; server status via `assign_async` or a cached value so pages are not blocked by the game server.
- **GameServer** is called directly from the context — no HTTP self-call.
- **GameServer** must decode JSON explicitly: OpenMU answers `/api/status` with `Content-Type: text/plain` (VERIFIED).
- Contexts: Accounts, Characters, Rankings, Guilds, News, GameServer, Settings.
- Implemented (Phase 2): `OpenMU.*` schemas + `OpenMU.Ids`, `News`, `Rankings`, `Guilds`, `GameServer` (+ `GameServer.Cache`), `Float32`, `Settings`; web: `NewsController`, `PageController`, `RankingLive`, `Api.StatusController` / `Api.RankingController` / `Api.GuildController`, `Sidebar` (plug + on_mount), `SiteComponents`, `NewsComponents`. Phase 3: `Accounts` (+ `CurrentAccount`, `Registration`), `UserAuth`, `SessionController`, `RegisterLive`, `AccountLive`, `Api.AccountController`, `Api.AuthController`, `Plugs.LenientParsers`. Phase 4: `Characters`, `CharactersLive`, `Api.CharacterController`, `CharacterMessages`. Phase 5: `News.create_article/3` / `delete_article/2`, `AdminNewsLive`, `AdminNewsController`, `Api.AdminNewsController`. Phase 6: `Api.FallbackController`, `Plugs.TrailingSlashRedirect`, JSON content type. Remaining: Phase 7 (parity & cutover).

## 3. Dependency mapping

| Current | Phoenix replacement |
|---|---|
| next, react, react-dom | phoenix, phoenix_live_view, phoenix_html |
| prisma, @prisma/client, @prisma/adapter-pg, pg | ecto_sql, postgrex |
| next-auth (Credentials, JWT), @next-auth/prisma-adapter | Plug.Session (signed+encrypted cookie) + custom plugs (phx.gen.auth pattern) |
| bcrypt (cost 10) | bcrypt_elixir (`log_rounds: 10`) |
| zod | Ecto.Changeset (schemaless for register / change password) |
| react-toastify | Phoenix flash (+ optional JS hook for toast look) |
| server `fetch` | Req |
| dotenv, `NEXT_PUBLIC_*` | `config/runtime.exs` |
| tailwindcss 3, postcss, autoprefixer | `tailwind` hex package pinned to **v3** (decision D4) with the current `tailwind.config` theme |
| next/image, next/font (Lora) | plain `<img>` from `priv/static/images`, Google Fonts `<link>` |
| eslint, typescript | credo, dialyxir (optional) |
