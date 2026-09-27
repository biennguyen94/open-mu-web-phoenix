defmodule OpenMuWeb.Repo do
  @moduledoc """
  Repo for the **existing** OpenMU PostgreSQL database.

  The schema is owned by the OpenMU game server (EF Core). This application only
  reads/writes rows; it never creates, drops or migrates OpenMU tables. The only
  website-owned table is `data."OpenMuWeb_News"`. See `../docs/DATABASE.md`.
  """
  use Ecto.Repo,
    otp_app: :open_mu_web,
    adapter: Ecto.Adapters.Postgres
end
