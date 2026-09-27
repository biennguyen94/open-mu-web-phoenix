defmodule OpenMuWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :open_mu_web,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {OpenMuWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.15"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.5", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:req, "~> 0.5"},
      {:bcrypt_elixir, "~> 3.0"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # The database is the EXISTING OpenMU database shared with the game server
  # (see ../CLAUDE.md and ../docs/DATABASE.md). Ecto does not own it, so the
  # generator's create/drop/reset/load aliases are replaced by guards that refuse
  # to run. The test database is provisioned by scripts/setup_test_db.sh.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "ecto.create": &refuse_destructive/1,
      "ecto.drop": &refuse_destructive/1,
      "ecto.reset": &refuse_destructive/1,
      "ecto.setup": &refuse_destructive/1,
      "ecto.load": &refuse_destructive/1,
      "ecto.rollback": &refuse_destructive/1,
      test: ["ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind open_mu_web", "esbuild open_mu_web"],
      "assets.deploy": [
        "tailwind open_mu_web --minify",
        "esbuild open_mu_web --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  defp refuse_destructive(_args) do
    Mix.raise("""
    Refusing to run: this project uses the existing OpenMU database, which must never be
    created, dropped, reset, loaded or rolled back by Ecto.
    For the test database use: scripts/setup_test_db.sh
    """)
  end
end
