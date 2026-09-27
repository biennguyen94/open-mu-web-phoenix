defmodule OpenMuWebWeb.Api.RankingControllerTest do
  use OpenMuWebWeb.ConnCase

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.OpenMU.Ids

  test "GET /api/characters/ranking/reset: top 50 with the Next.js keys and order", %{conn: conn} do
    set_stat!("test1Dw", Ids.resets(), 99.0)
    conn = get(conn, ~p"/api/characters/ranking/reset")
    rows = json_response(conn, 200)
    char = character!("test1Dw")

    assert length(rows) == 50

    assert hd(rows) == %{
             "CharacterId" => char.id,
             "Name" => "test1Dw",
             "CharacterClassId" => char.character_class_id,
             "resets" => 99,
             "lvl" => 11,
             "masterlvl" => 0
           }

    assert conn.resp_body =~
             ~s([{"CharacterId":"#{char.id}","Name":"test1Dw","CharacterClassId":"#{char.character_class_id}","resets":99,"lvl":11,"masterlvl":0})
  end

  test "GET /api/characters/ranking/killers", %{conn: conn} do
    update_character!("test2Dk", player_kill_count: 1000)
    conn = get(conn, ~p"/api/characters/ranking/killers")
    rows = json_response(conn, 200)
    char = character!("test2Dk")

    assert length(rows) == 30

    assert conn.resp_body =~
             ~s([{"Id":"#{char.id}","CharacterClassId":"#{char.character_class_id}","CurrentMapId":"#{char.current_map_id}","Name":"test2Dk","PlayerKillCount":1000})
  end

  describe "POST /api/characters/ranking/online" do
    test "returns the listed characters", %{conn: conn} do
      char = character!("test1Dk")

      conn =
        post(conn, ~p"/api/characters/ranking/online", %{
          "state" => "Online",
          "playersList" => ["test1Dk", "nobody"]
        })

      assert conn.resp_body ==
               ~s([{"Name":"test1Dk","CurrentMapId":"#{char.current_map_id}","CharacterClassId":"#{char.character_class_id}","PositionX":#{char.position_x},"PositionY":#{char.position_y}}])
    end

    test "empty list", %{conn: conn} do
      assert conn
             |> post(~p"/api/characters/ranking/online", %{"playersList" => []})
             |> json_response(200) == []
    end

    test "invalid bodies are rejected with 400", %{conn: conn} do
      error = %{"message" => "There was a problem try again later"}

      for body <- [%{"playersList" => [1, 2]}, %{"playersList" => "test1Dk"}] do
        assert build_conn()
               |> post(~p"/api/characters/ranking/online", body)
               |> json_response(400) == error
      end

      # R10 (deliberate difference): Next.js returned every character here.
      assert conn |> post(~p"/api/characters/ranking/online", %{}) |> json_response(400) == error
    end
  end
end
