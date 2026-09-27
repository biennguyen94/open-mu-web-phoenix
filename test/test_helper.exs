ExUnit.start()

# Safety net: the test database must be a disposable copy, never the OpenMU database.
repo_database = OpenMuWeb.Repo.config()[:database]

if repo_database in [nil, "", "openmu"] do
  raise "Refusing to run tests against #{inspect(repo_database)}; see scripts/setup_test_db.sh"
end

# The test database must be a full copy of the OpenMU database (see scripts/setup_test_db.sh).
case OpenMuWeb.Repo.query(~s|SELECT to_regclass('config."CharacterClass"') IS NOT NULL|) do
  {:ok, %{rows: [[true]]}} ->
    :ok

  _ ->
    raise """
    #{repo_database} is not a copy of the OpenMU database.
    Run: scripts/setup_test_db.sh
    """
end

Ecto.Adapters.SQL.Sandbox.mode(OpenMuWeb.Repo, :manual)
