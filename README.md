# OpenMU Web — Phoenix

A CMS website for MU Online private servers running [MUnique/OpenMU](https://github.com/MUnique/OpenMU),
written in **Elixir / Phoenix / LiveView / Ecto**.

It is a behavior-preserving port of the Next.js website
[biennguyen94/open-mu-web](https://github.com/biennguyen94/open-mu-web): same pages, same JSON API
(URLs, payloads, status codes), same game rules — working directly on the **existing OpenMU PostgreSQL
database** shared with the game server. The known security issues of the original were fixed
(see [Differences from the Next.js app](#differences-from-the-nextjs-app)).

## Features

- **Home / News** — paginated news list, news detail
- **Rankings** — top characters (resets → level → master level), top killers, top guilds with a member popup, online players
- **Server statistics** — online / offline state and online player count from the OpenMU admin panel, shown on every page
- **Account** — register, login / logout, change password
- **Character panel** — add stats, reset, reset stats, PK clear (zen costs and reset rules are configurable)
- **Game Master** — add / delete news
- **Static pages** — info, download (configurable links), terms and conditions
- **JSON API** — every `/api/*` endpoint of the Next.js app, byte-compatible responses

## Stack

| | |
|---|---|
| Language / runtime | Elixir 1.20, Erlang/OTP 28 |
| Web | Phoenix 1.8, LiveView 1.2, Bandit |
| Database | PostgreSQL (the OpenMU database), Ecto / Postgrex |
| UI | Tailwind CSS v3 (theme of the original site), self-hosted Lora font |
| Auth | bcrypt (`bcrypt_elixir`, hashes compatible with OpenMU), encrypted cookie session |
| HTTP client | Req (OpenMU admin panel `/api/status`) |

## Requirements

- Elixir 1.20 / Erlang/OTP 28 (or Docker only, for deployment)
- A running OpenMU stack: its PostgreSQL database (`openmu`) and, for the server status / online checks, the admin panel
- For tests: Docker access to the OpenMU `database` container (the test database is a copy of `openmu`)

## Quick start (development)

```bash
cp .env.example .env        # set DATABASE_URL (e.g. postgresql://USER:PASS@localhost:5433/openmu) and GAMESERVER_URL
mix setup                   # dependencies + assets — no database setup: the schema belongs to OpenMU
mix phx.server              # http://localhost:4001
```

## Configuration

Read at runtime (`config/runtime.exs`). Real environment variables win; in dev/test the `.env` file at
the repository root is used as a fallback. The website settings keep the variable names of the Next.js app.

| Variable | Meaning |
|---|---|
| `DATABASE_URL` | the OpenMU PostgreSQL database |
| `TEST_DATABASE_URL` | test database (default: `DATABASE_URL` with the database `open_mu_web_test`) |
| `GAMESERVER_URL` | OpenMU admin panel base URL (`/api/status` is appended) |
| `NEXT_PUBLIC_ZEN_TO_RESET`, `LVL_TO_RESET`, `MAX_RESET` | reset cost / minimum level / maximum resets (empty cost disables reset) |
| `NEXT_PUBLIC_ZEN_TO_PKCLEAR`, `NEXT_PUBLIC_ZEN_TO_RESET_STATS` | costs of PK clear and reset stats (empty disables) |
| `NEXT_PUBLIC_GOODLE_DRIVE_LINK`, `NEXT_PUBLIC_MEDIAFIRE_LINK`, `NEXT_PUBLIC_MEGA_LINK`, `NEXT_PUBLIC_DISCORD_LINK` | download / Discord links (empty hides them) |
| `SECRET_KEY_BASE`, `PHX_HOST`, `PHX_URL_SCHEME`, `PHX_URL_PORT`, `PHX_FORCE_SSL`, `PORT`, `POOL_SIZE` | production only |

## Database safety

The database is owned by the OpenMU game server (EF Core migrations). This application only reads and
writes rows:

- `mix ecto.create/drop/reset/setup/load/rollback` are **blocked** in `mix.exs`;
- Ecto keeps its bookkeeping in `public.openmu_web_schema_migrations` (never `__EFMigrationsHistory`);
- the only migration creates the website table `data."OpenMuWeb_News"` **if it does not exist**; its rollback is a no-op;
- the release has a `migrate` task but no rollback task, and nothing runs at startup.

## Tests

```bash
scripts/setup_test_db.sh    # (re)creates open_mu_web_test as a full copy of openmu (the source is only read)
mix test                    # or: mix precommit  (compile --warnings-as-errors, format, tests)
```

The test suite refuses to run against `openmu`. The game server is stubbed with `Req.Test`.

## Deployment (Docker)

A release image and a compose file that joins the OpenMU all-in-one Docker network
(`database:5432`, `openmu-startup:8080`) without changing the OpenMU stack:

```bash
cd deploy
cp .env.example .env        # SECRET_KEY_BASE (mix phx.gen.secret), DATABASE_URL, settings
docker compose up -d --build
```

The site is served on port 4000. Operations, smoke tests, HTTPS / VPS notes and rollback:
[docs/DEPLOY.md](docs/DEPLOY.md); deploying to a VPS: [docs/VPS.md](docs/VPS.md).

## Parity with the Next.js app

`scripts/parity/` runs the Next.js app and this app side by side on disposable copies of the database
(and a fake OpenMU status server) and compares API responses, HTTP behavior, pages, authentication,
character operations and admin news:

```bash
scripts/parity/run_all.sh   # needs a checkout of open-mu-web next to this repo (or NEXT_APP_DIR)
```

## Differences from the Next.js app

Kept identical: routes, API contracts, messages, status codes, game and ranking rules. Intentional
differences (full list in [docs/API.md](docs/API.md#intentional-differences-final-list)):

- **Security fixes** — password change only for the logged-in account; character operations only on
  the account's own characters; stat amounts must be non-negative integers; reset location taken from
  the database; operations run in locked transactions (no double spending); admin news and admin pages
  require a Game Master account server-side; the online-players API no longer leaks every character.
- **Fixed bugs** — news pagination and news detail work (broken in the Next.js 16 app).
- **Sessions** — the site uses its own encrypted cookie; users log in again after switching from the
  Next.js app. NextAuth protocol endpoints are replaced by `POST /login` / `DELETE /logout`.

Rules deliberately kept from the original (e.g. reset stats with base 20) are listed in
[docs/RISKS.md](docs/RISKS.md).

## Project structure

```text
lib/open_mu_web/        contexts: Accounts, Characters, Rankings, Guilds, News, GameServer, Settings
lib/open_mu_web/openmu/ Ecto schemas mapped onto the OpenMU tables + OpenMU ids (attributes, classes, maps)
lib/open_mu_web_web/    router, controllers (pages + /api), LiveViews, components, plugs
assets/                 Tailwind v3 config, CSS, JS (banner slider, dialogs, LiveView hooks)
priv/static/            images and font of the original site
deploy/                 docker-compose.yml, .env.example
scripts/                test database setup, parity tooling
docs/                   porting documentation (architecture, database, API, auth, risks, status, deployment)
```

## Documentation

Start with [docs/README.md](docs/README.md). Notes for contributors and AI agents:
[CLAUDE.md](CLAUDE.md), [AGENTS.md](AGENTS.md).

## Credits

Based on the OpenMU Web project by Nick "mamflo" Bubuioc and its modernized Next.js version
[open-mu-web](https://github.com/biennguyen94/open-mu-web). Designed to work with
[MUnique/OpenMU](https://github.com/MUnique/OpenMU). This site is in no way associated with or
endorsed by Webzen Inc.
