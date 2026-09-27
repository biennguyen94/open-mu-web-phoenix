# OpenMU Web — Phoenix

Elixir/Phoenix port of the Next.js OpenMU Web app in the parent directory.
Project docs: `../CLAUDE.md`, `../docs/` (status in `../docs/PORTING_STATUS.md`).

## Toolchain

Installed in user space from builds.hex.pm (no sudo): Erlang/OTP 28.5.0.7, Elixir 1.20.4, Phoenix 1.8.15.

```bash
export PATH="$HOME/.local/beam/otp/bin:$HOME/.local/beam/elixir/bin:$PATH"   # also added to ~/.bashrc
```

Optional (needs sudo): `sudo apt install inotify-tools` enables live reload in dev.

## Configuration

Settings come from environment variables, then `phoenix/.env`, then the repository root `.env`
shared with the Next.js app (dev/test only). Same variable names as the Next.js app — see
`.env.example`. The database is **the existing OpenMU database** (`DATABASE_URL`).
Tests use fixed settings from `config/test.exs` and stub the game server with `Req.Test`.

## Run

```bash
mix setup          # deps + assets (no database setup: the DB is owned by OpenMU)
mix phx.server     # http://localhost:4001 (Next.js keeps port 4000)
```

## Deploy (Docker)

See `../docs/DEPLOY.md`: `cd deploy && docker compose up -d --build` (release image, OpenMU Docker network, port 4000).

## Tests

```bash
scripts/setup_test_db.sh   # (re)creates open_mu_web_test as a full copy of openmu (source is only read)
mix test                   # runs `ecto.migrate` (website migration only) on the test DB, then the tests
```

`TEST_DATABASE_URL` overrides the test database; by default it is `DATABASE_URL` with the database
name replaced by `open_mu_web_test`. Tests refuse to run against `openmu`.

## Parity with the Next.js app

See `scripts/parity/README.md` (both apps on the same disposable DB copy + fake game server;
`api_parity.py`, `page_parity.py`).

## Database safety

- `mix ecto.create/drop/reset/setup/load/rollback` are blocked (see `mix.exs`).
- Ecto bookkeeping table: `public.openmu_web_schema_migrations` (never `__EFMigrationsHistory`).
- The only migration creates `data."OpenMuWeb_News"` **if not exists**; its rollback is a no-op.
- `Phoenix.Ecto.CheckRepoStatus` is disabled so dev pages never ask to migrate the OpenMU DB.
