# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :open_mu_web,
  ecto_repos: [OpenMuWeb.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# The database is the existing OpenMU database (EF Core owns its schema and
# `public."__EFMigrationsHistory"`). Ecto keeps its own bookkeeping table under a
# distinct name and must only ever run the website's non-destructive migrations.
config :open_mu_web, OpenMuWeb.Repo, migration_source: "openmu_web_schema_migrations"

# OpenMU game server client (GAMESERVER_URL comes from runtime settings).
# The status used by the sidebar is cached briefly; /api/status and online checks
# always fetch fresh data.
config :open_mu_web, OpenMuWeb.GameServer,
  req_options: [receive_timeout: 3_000, connect_options: [timeout: 2_000], retry: false],
  cache_ttl_ms: 5_000

# Configure the endpoint
config :open_mu_web, OpenMuWebWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: OpenMuWebWeb.ErrorHTML, json: OpenMuWebWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: OpenMuWeb.PubSub,
  live_view: [signing_salt: "QFkC7KrX"]

# Configure LiveView
config :phoenix_live_view,
  # the attribute set on all root tags. Used for Phoenix.LiveView.ColocatedCSS.
  root_tag_attribute: "phx-r"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  open_mu_web: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required). Pinned to v3 for UI parity with
# the Next.js app (decision D4); the theme lives in assets/tailwind.config.js.
config :tailwind,
  version: "3.4.17",
  open_mu_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/css/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
