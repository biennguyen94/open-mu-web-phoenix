import Config

# Database: a disposable full copy of the OpenMU database (see
# scripts/setup_test_db.sh), configured in config/runtime.exs. Never `openmu`.
config :open_mu_web, OpenMuWeb.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :open_mu_web, OpenMuWebWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ZUS3e89fbhSOK3tqpusbvDe/gtYkW/tMS+stwasC7xizvNNV7NbiCGfFR0R/YLuy",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true

# Game server HTTP calls are stubbed with Req.Test in tests; no status caching.
config :open_mu_web, OpenMuWeb.GameServer,
  req_options: [plug: {Req.Test, OpenMuWeb.GameServer}, retry: false],
  cache_ttl_ms: 0

# Fixed website settings for tests (runtime.exs does not read env/.env for :test).
config :open_mu_web, :settings,
  game_server_url: "http://game-server.test",
  google_drive_link: "https://drive.example/client",
  mediafire_link: "",
  mega_link: "https://mega.example/client",
  discord_link: "https://discord.example/invite",
  zen_to_reset: "1000000",
  lvl_to_reset: "400",
  max_reset: "6",
  zen_to_pkclear: "1000000",
  zen_to_reset_stats: "1000000"

# Cheap bcrypt in tests (production uses cost 10 like the Next.js app, see OpenMuWeb.Accounts).
config :bcrypt_elixir, :log_rounds, 4
