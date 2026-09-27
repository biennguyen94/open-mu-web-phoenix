import Config

# ---------------------------------------------------------------------------
# Environment loading
#
# Real environment variables always win. In dev/test, missing values are read
# from `phoenix/.env` and then from the repository root `.env` shared with the
# Next.js app, so both apps run against the same configuration.
# ---------------------------------------------------------------------------
read_dotenv = fn path ->
  if File.exists?(path) do
    path
    |> File.read!()
    |> String.split(~r/\R/)
    |> Enum.reduce(%{}, fn line, acc ->
      case Regex.run(~r/^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/, line) do
        [_, key, value] ->
          value =
            case Regex.run(~r/^"(.*)"$|^'(.*)'$/, value) do
              [_, dq] -> dq
              [_, "", sq] -> sq
              nil -> value |> String.split(" #", parts: 2) |> hd() |> String.trim()
            end

          Map.put(acc, key, value)

        nil ->
          acc
      end
    end)
  else
    %{}
  end
end

dotenv =
  if config_env() in [:dev, :test] do
    Map.merge(
      read_dotenv.(Path.expand("../../.env", __DIR__)),
      read_dotenv.(Path.expand("../.env", __DIR__))
    )
  else
    %{}
  end

env = fn key, default -> System.get_env(key) || Map.get(dotenv, key) || default end

# ---------------------------------------------------------------------------
# Website settings (same variable names as the Next.js app; see
# ../docs/ARCHITECTURE.md). Raw strings are parsed by OpenMuWeb.Settings.
# An empty value disables the corresponding feature, exactly like the Next.js app.
# ---------------------------------------------------------------------------
# Tests use fixed settings from config/test.exs (independent of any .env file).
if config_env() != :test do
  config :open_mu_web, :settings,
    game_server_url: env.("GAMESERVER_URL", nil),
    google_drive_link: env.("NEXT_PUBLIC_GOODLE_DRIVE_LINK", nil),
    mediafire_link: env.("NEXT_PUBLIC_MEDIAFIRE_LINK", nil),
    mega_link: env.("NEXT_PUBLIC_MEGA_LINK", nil),
    discord_link: env.("NEXT_PUBLIC_DISCORD_LINK", nil),
    zen_to_reset: env.("NEXT_PUBLIC_ZEN_TO_RESET", nil),
    lvl_to_reset: env.("LVL_TO_RESET", nil),
    max_reset: env.("MAX_RESET", nil),
    zen_to_pkclear: env.("NEXT_PUBLIC_ZEN_TO_PKCLEAR", nil),
    zen_to_reset_stats: env.("NEXT_PUBLIC_ZEN_TO_RESET_STATS", nil)
end

# ---------------------------------------------------------------------------
# Database (dev/test). Prod is configured further below.
# ---------------------------------------------------------------------------
database_name = fn url -> url |> URI.parse() |> Map.get(:path, "") |> String.trim_leading("/") end

case config_env() do
  :dev ->
    database_url =
      env.("DATABASE_URL", nil) ||
        raise """
        DATABASE_URL is missing. Set it in the environment, in phoenix/.env or in the
        repository root .env (the Next.js app's file), e.g.
        postgresql://USER:PASS@localhost:5433/openmu
        """

    config :open_mu_web, OpenMuWeb.Repo, url: database_url

  :test ->
    # TEST_DATABASE_URL, or DATABASE_URL with the database replaced by
    # open_mu_web_test (+ MIX_TEST_PARTITION).
    test_url =
      case env.("TEST_DATABASE_URL", nil) do
        nil ->
          base =
            env.("DATABASE_URL", nil) ||
              raise "TEST_DATABASE_URL or DATABASE_URL is required to run the tests"

          base
          |> URI.parse()
          |> Map.put(:path, "/open_mu_web_test#{System.get_env("MIX_TEST_PARTITION")}")
          |> URI.to_string()

        url ->
          url
      end

    if database_name.(test_url) == "openmu" do
      raise "Refusing to run tests against the OpenMU database `openmu`. Use a disposable copy."
    end

    config :open_mu_web, OpenMuWeb.Repo, url: test_url

  :prod ->
    :ok
end

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/open_mu_web start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :open_mu_web, OpenMuWebWeb.Endpoint, server: true
end

config :open_mu_web, OpenMuWebWeb.Endpoint,
  # Default 4001 so Phoenix can run next to the Next.js app (port 4000).
  http: [port: String.to_integer(System.get_env("PORT", "4001"))]

if config_env() == :dev do
  # Reload browser tabs when matching files change.
  config :open_mu_web, OpenMuWebWeb.Endpoint,
    live_reload: [
      web_console_logger: true,
      patterns: [
        # Static assets, except user uploads
        ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
        # Gettext translations
        ~r"priv/gettext/.*\.po$"E,
        # Router, Controllers, LiveViews and LiveComponents
        ~r"lib/open_mu_web_web/router\.ex$"E,
        ~r"lib/open_mu_web_web/(controllers|live|components)/.*\.(ex|heex)$"E
      ]
    ]
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :open_mu_web, OpenMuWeb.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    # For machines with several cores, consider starting multiple pools of `pool_size`
    # pool_count: 4,
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"

  config :open_mu_web, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :open_mu_web, OpenMuWebWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://bandit.hexdocs.pm/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :open_mu_web, OpenMuWebWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://plug.hexdocs.pm/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :open_mu_web, OpenMuWebWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
