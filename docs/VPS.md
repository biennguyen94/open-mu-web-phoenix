# Deploying to a VPS

What changes compared with the local Docker deployment on WSL ([DEPLOY.md](DEPLOY.md)).
No code change is required; it is configuration, networking and security.

## 1. Required: `deploy/.env` on the VPS

| Variable | Value on the VPS |
|---|---|
| `SECRET_KEY_BASE` | **generate a new one on the VPS** (never reuse the WSL one): `openssl rand -base64 48` — no Elixir needed |
| `PHX_HOST` | the VPS IP or domain |
| `PHX_URL_SCHEME` / `PHX_URL_PORT` | direct access by IP: `http` / `4000`; behind HTTPS: `https` / `443` |
| `DATABASE_URL` | `postgresql://postgres:<VPS database password>@database:5432/openmu` |
| `GAMESERVER_URL` | unchanged: `http://openmu-startup:8080` |
| zen costs, reset rules, download / Discord links | values of your server |

The compose file joins the OpenMU network `all-in-one_default`. If the OpenMU compose directory on
the VPS is **not** named `all-in-one`, the network name differs: check with `docker network ls` and
set `OPENMU_NETWORK=<name>` (in the shell or next to `docker compose`).

## 2. Port 80 is already taken

The OpenMU stack serves its **admin panel** on port 80 (`nginx-80`). Two options:

- **Simple:** keep the site on port 4000 — users open `http://<VPS IP>:4000`, like the old Next.js site.
- **Recommended:** a domain and a reverse proxy (e.g. Caddy, which obtains HTTPS certificates
  automatically): `mu.example.com` → `openmu-web:4000`; the admin panel on another domain or only
  reachable internally. Then set `PHX_URL_SCHEME=https`, `PHX_URL_PORT=443`, `PHX_FORCE_SSL=true`.
  The proxy must forward the `Host` and `X-Forwarded-Proto` headers and **websocket upgrades**
  (LiveView uses `/live`). Caddy does all three by default.

LiveView accepts websocket connections from the origin the page was served from
(`check_origin: :conn`), so it works with the IP or the domain without extra configuration.

## 3. Security on the Internet

- **Firewall:** open only the web port (4000, or 80/443) and the game ports (`44405-44406`,
  `55901-55906`, `55980`). **Close PostgreSQL**: the OpenMU compose files publish the database on
  `0.0.0.0:5433` and on a random host port — on a VPS that exposes the database to the Internet. Also
  close `8081` and the other random host ports.
- **PostgreSQL password:** the local setup uses a short default password. Use a strong one on the VPS
  (in the OpenMU stack configuration) and put it in `DATABASE_URL`.
- **OpenMU admin panel:** do not leave it public on port 80.
- **Default test accounts (decision D7):** they were accepted for publishing, but on a public server
  anyone can log in as `testgm` / `testgm` (password = login name) and add or delete news.
- **Session cookie:** it is signed, encrypted, `HttpOnly` and `SameSite=Lax`, but does not set the
  `Secure` flag yet. Recommended when serving over HTTPS (small code change in
  `lib/open_mu_web_web/endpoint.ex`, e.g. enabled together with `PHX_FORCE_SSL`).

## 4. Database on the VPS

- **Fresh OpenMU database without the news table:** run once
  `docker compose run --rm openmu-web bin/migrate`. It only creates `data."OpenMuWeb_News"` and the
  bookkeeping table `public.openmu_web_schema_migrations`. If the VPS already ran the Next.js site,
  the table exists and nothing is needed.
- **Different OpenMU version / configuration than the development machine:** check the attribute,
  character class and map ids the site relies on ([DATABASE.md](DATABASE.md) §3), with read-only
  queries.
- **Back up before the first deployment:**
  `docker exec database pg_dump -U postgres openmu > openmu-backup.sql`

## 5. Build and deploy

```bash
git clone https://github.com/biennguyen94/open-mu-web-phoenix.git
cd open-mu-web-phoenix/deploy
cp .env.example .env        # fill in as in section 1
docker compose up -d --build
```

- Building the image needs about 1.5–2 GB of RAM; the running container about 200 MB. On a small
  VPS add swap, or build elsewhere and transfer the image (`docker save` / `docker load`, or a
  registry).
- ARM VPS (e.g. Oracle Ampere): build on the VPS itself — the base images are available for arm64.
- Node.js, Elixir and the Next.js app are **not** needed on the VPS.
- Updates: `git pull && docker compose up -d --build`.

## Checklist

- [ ] OpenMU stack running on the VPS; network name checked (`OPENMU_NETWORK` if needed)
- [ ] `deploy/.env` with a new `SECRET_KEY_BASE`, `PHX_HOST`, URL scheme/port, `DATABASE_URL`, settings
- [ ] Database backup taken; news table present (or `bin/migrate` run once)
- [ ] Firewall: only web + game ports open; PostgreSQL, 8081 and random ports closed
- [ ] Strong PostgreSQL password; admin panel not public
- [ ] HTTPS via reverse proxy (optional but recommended) + `Secure` session cookie
- [ ] Smoke test: `/`, `/api/status` (201 Online), login, `/characters` (see [DEPLOY.md](DEPLOY.md))
