defmodule OpenMuWebWeb.RankingLiveTest do
  use OpenMuWebWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenMuWeb.Fixtures

  alias OpenMuWeb.OpenMU.Ids

  test "defaults to Top Characters", %{conn: conn} do
    set_stat!("test1Dw", Ids.resets(), 99.0)
    {:ok, view, html} = live(conn, ~p"/ranking")

    assert html =~ "Top Rankings"
    assert has_element?(view, "th", "Master Level")
    assert has_element?(view, "tbody tr:first-child td", "test1Dw")
    assert has_element?(view, "tbody tr:first-child img[src='/images/avatars/dw.jpg']")
  end

  test "switching tabs patches the URL", %{conn: conn} do
    update_character!("test2Dk", player_kill_count: 1000)
    {:ok, view, _html} = live(conn, ~p"/ranking")

    view |> element("button#topKillers") |> render_click()
    assert_patch(view, ~p"/ranking?tab=topKillers")
    assert has_element?(view, "th", "Kill Count")
    assert has_element?(view, "tbody tr:first-child td", "1000")
    assert has_element?(view, "tbody tr:first-child td", "Lorencia")
  end

  test "top guilds with the member popup on hover", %{conn: conn} do
    insert_guild!("Alpha", 120, members: [{"testgmDk", 2}, {"test1Dk", 1}])
    insert_guild!("Empty", 5)
    {:ok, view, _html} = live(conn, ~p"/ranking?tab=topGuilds")

    assert has_element?(view, "#guild-0 th", "Alpha")

    view
    |> element("#guild-0")
    |> render_hook("guild_hover", %{"index" => 0, "x" => 10, "y" => 20})

    assert has_element?(view, "#guild-0 div[style='left: 10px; top: 20px']")
    assert has_element?(view, "#guild-0 div", "Guild Master")
    assert has_element?(view, "#guild-0 div", "test1Dk")

    view |> element("#guild-0") |> render_hook("guild_leave", %{})
    refute has_element?(view, "#guild-0 div", "Guild Master")

    # Guild without members: popup + error toast, like the Next.js client (API 400).
    html =
      view
      |> element("#guild-1")
      |> render_hook("guild_hover", %{"index" => 1, "x" => 1, "y" => 1})

    assert html =~ "There was en error!"
  end

  test "online players come from the game server status", %{conn: conn} do
    stub_game_server_online(["test1Dk", "ghost"])
    {:ok, view, _html} = live(conn, ~p"/ranking?tab=online")

    assert has_element?(view, "tbody tr td", "test1Dk")
    refute has_element?(view, "tbody tr td", "ghost")
    assert has_element?(view, "th", "Position")
  end

  test "online tab shows an error when the game server is down", %{conn: conn} do
    stub_game_server_down()
    {:ok, _view, html} = live(conn, ~p"/ranking?tab=online")
    assert html =~ "There was a problem trying to find the online users. Try again later."
  end
end
