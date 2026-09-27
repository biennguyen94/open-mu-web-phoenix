defmodule OpenMuWebWeb.Api.CharacterControllerTest do
  use OpenMuWebWeb.ConnCase

  import OpenMuWeb.Fixtures

  @zeros %{"str" => 0, "agi" => 0, "vit" => 0, "ene" => 0, "lead" => 0}

  defp call(conn, route, body), do: post(conn, "/api/characters/#{route}", body)

  defp message(conn, status), do: json_response(conn, status)["message"]

  test "anonymous: per-route status and message", %{conn: conn} do
    assert conn |> call("addstats", %{"name" => "test1Dk"}) |> message(500) ==
             "You can't do this!"

    assert build_conn() |> call("pkclear", %{"name" => "test1Dk"}) |> message(500) ==
             "You can't do this!"

    assert build_conn() |> call("reset", %{"name" => "test1Dk"}) |> message(400) ==
             "You can't do this!"

    assert build_conn() |> call("resetStats", %{"name" => "test1Dk"}) |> message(400) ==
             "You can't do this!"
  end

  describe "logged in as test1" do
    setup %{conn: conn}, do: %{conn: log_in(conn, "test1")}

    test "success messages", %{conn: conn} do
      assert conn
             |> call("addstats", Map.merge(@zeros, %{"name" => "test1Dk", "str" => 1}))
             |> message(200) ==
               "Character points added succesfuly"

      assert conn |> call("pkclear", %{"name" => "test1Elf"}) |> message(200) ==
               "PkClear successfully"

      assert conn |> call("resetStats", %{"name" => "test1Dw", "clasId" => "x"}) |> message(200) ==
               "Points were reseted succesffuly"
    end

    test "not owned characters (R3)", %{conn: conn} do
      assert conn |> call("pkclear", %{"name" => "test400Dk"}) |> message(500) ==
               "You can't do this!"

      assert conn |> call("reset", %{"name" => "test400Dk"}) |> message(400) ==
               "You can't do this! Try to Login again."

      assert conn |> call("resetStats", %{"name" => "test400Dk"}) |> message(400) ==
               "You can't do this!"

      assert conn |> call("addstats", Map.put(@zeros, "name", "test400Dk")) |> message(500) ==
               "You can't do this!"
    end

    test "rule messages", %{conn: conn} do
      assert conn
             |> call("addstats", Map.merge(@zeros, %{"name" => "test1Dk", "str" => 1000}))
             |> message(400) ==
               "You don't have enough points!"

      assert conn
             |> call("addstats", Map.merge(@zeros, %{"name" => "test1Dk", "str" => -1}))
             |> message(400) ==
               "There was a problem try again later"

      assert conn |> call("reset", %{"name" => "test1Dk"}) |> message(400) ==
               "You aren't lvl 400 or you are at maximum reset 6"

      set_money!("test1Elf", 0)

      assert conn |> call("pkclear", %{"name" => "test1Elf"}) |> message(400) ==
               "You don't have enough zen: 1000000"
    end

    test "online character and unreachable game server", %{conn: conn} do
      stub_game_server_online(["test1Elf"])

      assert conn |> call("pkclear", %{"name" => "test1Elf"}) |> message(400) ==
               "Disconnect from your account!"

      stub_game_server_down()

      assert conn |> call("pkclear", %{"name" => "test1Elf"}) |> message(500) ==
               "Couldn't reach the server, try again later"
    end

    test "invalid JSON bodies", %{conn: conn} do
      raw = fn route ->
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/characters/#{route}", "x")
      end

      assert raw.("addstats") |> message(400) == "There was a problem try again later"
      assert raw.("pkclear") |> message(400) == "There was a problem try again later"
      assert raw.("reset") |> message(400) == "There was a problem while resetting your character"
      assert raw.("resetStats") |> message(400) == "There was a problem while reseting the points"
    end
  end

  test "disabled operations answer 'Function disabled' before anything else", %{conn: conn} do
    original = Application.get_env(:open_mu_web, :settings)

    Application.put_env(
      :open_mu_web,
      :settings,
      Keyword.merge(original, zen_to_reset: "", zen_to_pkclear: "", zen_to_reset_stats: "")
    )

    on_exit(fn -> Application.put_env(:open_mu_web, :settings, original) end)

    for route <- ~w(reset pkclear resetStats) do
      assert build_conn() |> call(route, %{"name" => "x"}) |> message(400) == "Function disabled"
    end

    # addstats has no zen cost
    assert conn |> call("addstats", %{"name" => "x"}) |> message(500) == "You can't do this!"
  end
end
