defmodule OpenMuWebWeb.Api.StatusControllerTest do
  use OpenMuWebWeb.ConnCase

  import OpenMuWeb.Fixtures

  test "relays the game server status with 201", %{conn: conn} do
    stub_game_server_online(["test1Dk"])
    conn = get(conn, ~p"/api/status")

    assert conn.status == 201
    assert conn.resp_body == ~s({"state":"Online","players":1,"playersList":["test1Dk"]})
    assert ["application/json" <> _] = get_resp_header(conn, "content-type")
  end

  test "non-2xx game server answer", %{conn: conn} do
    stub_game_server_status(502)
    conn = get(conn, ~p"/api/status")
    assert json_response(conn, 500) == %{"message" => "Couldn't connect to the gameserver"}
  end

  test "unreachable game server", %{conn: conn} do
    stub_game_server_down()

    assert conn |> get(~p"/api/status") |> json_response(500) == %{
             "message" => "There was an error"
           }
  end

  test "answers JSON regardless of the Accept header", %{conn: conn} do
    conn = conn |> put_req_header("accept", "text/html") |> get(~p"/api/status")
    assert conn.status == 201
  end
end
