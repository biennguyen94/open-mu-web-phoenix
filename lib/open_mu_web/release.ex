defmodule OpenMuWeb.Release do
  @moduledoc """
  Release tasks (no Mix in production).

  `migrate/0` only runs this project's migrations (`priv/repo/migrations`): the
  news-table guard (`CREATE TABLE IF NOT EXISTS`) and the Ecto bookkeeping table
  `openmu_web_schema_migrations`. It never touches OpenMU tables. There is no
  rollback task on purpose (the OpenMU database must not be rolled back).
  """
  @app :open_mu_web

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    # Many platforms require SSL when connecting to the database
    Application.ensure_all_started(:ssl)
    Application.ensure_loaded(@app)
  end
end
