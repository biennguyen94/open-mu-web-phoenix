defmodule OpenMuWeb.GameServerTest do
  use ExUnit.Case, async: true

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.GameServer

  test "decodes the text/plain JSON body and keeps key order" do
    stub_game_server_online(["test1Dk"])

    assert {:ok, status} = GameServer.status()
    assert Jason.encode!(status) == ~s({"state":"Online","players":1,"playersList":["test1Dk"]})
    assert GameServer.players_list(status) == ["test1Dk"]
  end

  test "non-2xx answers" do
    stub_game_server_status(503)
    assert GameServer.status() == {:error, {:http_status, 503}}
  end

  test "unreachable game server" do
    stub_game_server_down()
    assert GameServer.status() == {:error, :unreachable}
    assert GameServer.players_list(GameServer.status()) == []
  end

  test "invalid body" do
    stub_game_server_body("not json")
    assert GameServer.status() == {:error, :invalid_body}
  end

  test "requests GAMESERVER_URL/api/status" do
    Req.Test.stub(OpenMuWeb.GameServer, fn conn ->
      assert conn.host == "game-server.test"
      assert conn.request_path == "/api/status"
      Plug.Conn.send_resp(conn, 200, ~s({"state":"Online","players":0,"playersList":[]}))
    end)

    assert {:ok, _} = GameServer.status()
  end
end
