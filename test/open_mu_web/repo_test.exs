defmodule OpenMuWeb.RepoTest do
  use OpenMuWeb.DataCase, async: true

  alias OpenMuWeb.Repo

  defp scalar(sql) do
    %{rows: [[value]]} = Repo.query!(sql)
    value
  end

  test "Ecto bookkeeping never uses the EF Core migrations table" do
    assert Repo.config()[:migration_source] == "openmu_web_schema_migrations"
  end

  test "the test database is a full OpenMU copy (config reference rows present)" do
    assert scalar(~s|SELECT count(*) FROM config."CharacterClass"|) == 18

    assert scalar(
             ~s|SELECT count(*) FROM config."AttributeDefinition" WHERE "Designation" = 'Resets'|
           ) >= 1

    assert scalar(~s|SELECT to_regclass('public."__EFMigrationsHistory"') IS NOT NULL|)
  end

  test "the website news table exists with the documented columns" do
    columns =
      Repo.query!("""
      SELECT column_name, data_type FROM information_schema.columns
      WHERE table_schema = 'data' AND table_name = 'OpenMuWeb_News' ORDER BY ordinal_position
      """).rows

    assert columns == [
             ["id", "uuid"],
             ["title", "text"],
             ["body", "text"],
             ["author", "text"],
             ["creationDate", "timestamp without time zone"]
           ]
  end
end
