# Deployment (Phoenix on Docker, WSL)

Status: deployed 2026-09-27 on the WSL Docker host, next to the OpenMU all-in-one stack.

## Topology

```text
Docker host (WSL2)
├── OpenMU all-in-one  (/home/bien_nguyen/OpenMU/deploy/all-in-one, network all-in-one_default)
│   ├── database        postgres, DB `openmu`        host 5433 → 5432
│   ├── openmu-startup  game server + admin panel    host 8081 → 8080, game ports 44405-44406, 55901-55906, 55980
│   └── nginx-80        admin panel on host port 80
└── OpenMU Web          (this repository, deploy/, compose project `openmu-web`)
    └── openmu-web      image openmu-web-phoenix:latest, host 4000 → 4000, restart unless-stopped
        ├── DATABASE_URL   → database:5432/openmu      (existing OpenMU DB)
        └── GAMESERVER_URL → http://openmu-startup:8080 (/api/status)
```

The website joins the external network `all-in-one_default`; nothing in the OpenMU stack was changed.
Open the site at **http://localhost:4000** (WSL forwards localhost to Windows).

## Files

| File | Purpose |
|---|---|
| `Dockerfile`, `.dockerignore`, `rel/` | release image (builder `hexpm/elixir:1.20.4-erlang-28.5.0.7-debian-trixie-20260918-slim`, runner `debian:trixie-20260918-slim`) |
| `deploy/docker-compose.yml` | service `openmu-web` |
| `deploy/.env.example` | all variables (copy to `.env`) |
| `deploy/.env` | real values — **gitignored**, `chmod 600` (generated `SECRET_KEY_BASE`, DB credentials of the OpenMU stack) |

Environment variables: `SECRET_KEY_BASE`, `PHX_HOST` (host / IP used to reach the site), `PHX_URL_SCHEME` (default `http`), `PHX_URL_PORT` (default 4000), optional `PHX_FORCE_SSL=true` (only behind HTTPS), `DATABASE_URL`, `POOL_SIZE`, `GAMESERVER_URL`, and the website settings with the Next.js names (`NEXT_PUBLIC_ZEN_TO_RESET`, `LVL_TO_RESET`, `MAX_RESET`, `NEXT_PUBLIC_ZEN_TO_PKCLEAR`, `NEXT_PUBLIC_ZEN_TO_RESET_STATS`, download / Discord links). Optional compose variables: `WEB_PORT` (host port, default 4000), `OPENMU_NETWORK` (default `all-in-one_default`).

## Operations

```bash
cd deploy
docker compose up -d --build        # first deploy / update after `git pull`
docker compose logs -f openmu-web   # logs
docker compose restart openmu-web
docker compose down                 # stop the website (OpenMU keeps running)
```

Smoke test after a deploy (read-only):

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:4000/        # 200
curl -s http://localhost:4000/api/status                               # 201 {"state":"Online",...}
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:4000/api/characters/ranking/reset   # 200
```

The OpenMU stack must be running first (the website needs `database`; without `openmu-startup` the site works but shows the server offline and refuses character operations, like the Next.js app).

## Database

- No migration runs at startup. The news table `data."OpenMuWeb_News"` already exists in `openmu`.
- On a database without the news table: `docker compose run --rm openmu-web bin/migrate` — creates it
  (`CREATE TABLE IF NOT EXISTS`) and the bookkeeping table `public.openmu_web_schema_migrations`. Nothing else.
- There is no rollback task. Never drop/reset the OpenMU database.

## Rollback to the Next.js app

```bash
cd deploy && docker compose down
# in a checkout of https://github.com/biennguyen94/open-mu-web (with its .env):
npm ci && npm run build && npm start   # Next.js on port 4000
```

The database is shared and unchanged by the switch (both apps read/write the same rows). Sessions do not carry over in either direction: users log in again.

## HTTPS / VPS

Full guide: [VPS.md](VPS.md).


- On a VPS reached by IP or domain, set `PHX_HOST` (and `WEB_PORT` if needed). LiveView websockets accept the origin the page was served from (`check_origin: :conn`).
- Behind an HTTPS reverse proxy: `PHX_URL_SCHEME=https`, `PHX_URL_PORT=443`, `PHX_FORCE_SSL=true` (the proxy must send `X-Forwarded-Proto`).

## Security notes at cutover

- **R7**: the Phoenix site does not use `NEXTAUTH_SECRET` (it has its own `SECRET_KEY_BASE`, never committed). The `.env` of the Next.js repository (open-mu-web) is still **tracked in git** there and contains the database password; remove it from the index (`git rm --cached .env`, add it to `.gitignore`) and rotate the Postgres password — which also requires updating the OpenMU compose configuration (outside this repository; not done).
- **R9** (accepted, decision D7): the OpenMU default test accounts (password = login name, including GM accounts `testgm` / `testgm2`) are test data; publishing with them is accepted by the owner.
- Admin panel (`nginx-80`, port 80) is exposed on the host by the OpenMU stack, independent of the website.

## Verification at deployment (2026-09-27)

- Staging container from the same image on a DB copy (`openmu_parity`, port 4102): pages, assets (digested CSS/JS, images, font), `/api/status` through the Docker network, login + `/characters`, LiveView websocket (101 for same origin with `localhost` and `127.0.0.1`, 403 for a foreign origin).
- Production container on `openmu`: all public pages 200, `/api/status` 201 Online (real game server), rankings, trailing-slash 308, guards (302), GM login → `/characters`, `/account`, `/admin/news` 200, websocket 101. Only reads were performed on `openmu`; verified afterwards that no table was created (no `openmu_web_schema_migrations`) and no news row was written.
- Full parity suite (`run_all.sh`) passed twice at the end of Phase 6 with the same application code; a third run after deployment was killed by the host (out of memory — ~3.8 GB RAM with the OpenMU stack, the production container, Next.js dev and Phoenix dev running together). Re-run it with the production container stopped, or on a machine with more memory, when needed.

## Not verified (manual)

- The site in a real browser on Windows (visual check, toasts, delete dialog, banner slider).
- Game client login with an account registered / a password changed on the new site (`$2b$` bcrypt; OpenMU uses BCrypt.Net-Next `Verify`, which supports it).
- In-game effects of reset / PK clear / stats (see RISKS B3, B4, B14).
