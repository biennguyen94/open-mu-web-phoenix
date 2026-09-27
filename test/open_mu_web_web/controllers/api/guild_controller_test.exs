defmodule OpenMuWebWeb.Api.GuildControllerTest do
  use OpenMuWebWeb.ConnCase

  import OpenMuWeb.Fixtures

  setup do
    alpha =
      insert_guild!("Alpha", 120,
        logo: <<1, 2, 255>>,
        notice: "hello",
        members: [{"testgmDk", 2}]
      )

    beta = insert_guild!("Beta", 80)
    %{alpha: alpha, beta: beta}
  end

  test "GET /api/guilds returns every column, Logo like Prisma Bytes", %{
    conn: conn,
    alpha: alpha,
    beta: beta
  } do
    conn = get(conn, ~p"/api/guilds")

    assert conn.resp_body ==
             ~s([{"Id":"#{alpha.id}","HostilityId":null,"AllianceGuildId":null,"Name":"Alpha","Logo":{"0":1,"1":2,"2":255},"Score":120,"Notice":"hello"},) <>
               ~s({"Id":"#{beta.id}","HostilityId":null,"AllianceGuildId":null,"Name":"Beta","Logo":null,"Score":80,"Notice":null}])
  end

  test "GET /api/guilds/:name", %{conn: conn} do
    assert conn |> get(~p"/api/guilds/Alpha") |> response(200) ==
             ~s([{"Name":"testgmDk","guildStatus":2}])
  end

  test "unknown or empty guild -> 400 with the original key typo", %{conn: conn} do
    assert conn |> get(~p"/api/guilds/Beta") |> response(400) ==
             ~s({"messasge":"Guild wasn't found"})

    assert build_conn() |> get(~p"/api/guilds/Nope") |> response(400) ==
             ~s({"messasge":"Guild wasn't found"})
  end
end
