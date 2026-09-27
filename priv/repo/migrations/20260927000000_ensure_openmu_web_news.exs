defmodule OpenMuWeb.Repo.Migrations.EnsureOpenMuWebNews do
  @moduledoc """
  The only migration this project may run against the OpenMU database.

  Creates the website-owned news table exactly as documented in the README /
  `docs/DATABASE.md` if it does not exist yet. It never alters OpenMU tables and
  its rollback is a no-op, so news data can never be dropped by Ecto.
  """
  use Ecto.Migration

  def up do
    execute("""
    CREATE TABLE IF NOT EXISTS data."OpenMuWeb_News" (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        author TEXT NOT NULL,
        "creationDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """)
  end

  def down, do: :ok
end
