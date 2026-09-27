defmodule OpenMuWebWeb.AdminNewsLiveTest do
  use OpenMuWebWeb.ConnCase

  import Phoenix.LiveViewTest

  test "only Game Masters (server-side, R6)", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/", flash: %{"error" => "You can't do this!"}}}} =
             live(conn, ~p"/admin/news")

    assert {:error, {:redirect, %{to: "/"}}} =
             build_conn() |> log_in("test1") |> live(~p"/admin/news")

    assert build_conn() |> log_in("test1") |> get(~p"/admin/news") |> redirected_to() == "/"
  end

  test "adds a news article", %{conn: conn} do
    {:ok, view, html} = conn |> log_in("testgm") |> live(~p"/admin/news")
    assert html =~ "Add News"
    assert html =~ ~s(maxlength="200")
    assert html =~ ~s(maxlength="3000")

    html =
      view
      |> form("#news-form", news: %{title: "Server update", body: "Line 1\nLine 2"})
      |> render_submit()

    assert html =~ "News added successfully"

    article = OpenMuWeb.Repo.get_by!(OpenMuWeb.News.Article, title: "Server update")
    assert article.body == "Line 1\nLine 2"
    assert article.author == "testgmDk"
  end
end
