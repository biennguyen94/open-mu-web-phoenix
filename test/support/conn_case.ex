defmodule OpenMuWebWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use OpenMuWebWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint OpenMuWebWeb.Endpoint

      use OpenMuWebWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import OpenMuWebWeb.ConnCase
    end
  end

  setup {Req.Test, :set_req_test_from_context}

  setup tags do
    OpenMuWeb.DataCase.setup_sandbox(tags)
    # Every page renders the sidebar, which asks the game server for its status.
    OpenMuWeb.Fixtures.stub_game_server_online()
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc "Logs the given OpenMU account (login name) into the conn's session."
  def log_in(conn, login_name) do
    account = OpenMuWeb.Repo.get_by!(OpenMuWeb.OpenMU.Account, login_name: login_name)
    Plug.Test.init_test_session(conn, %{"account_id" => account.id})
  end
end
