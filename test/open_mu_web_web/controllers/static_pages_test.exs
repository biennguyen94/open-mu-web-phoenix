defmodule OpenMuWebWeb.StaticPagesTest do
  use OpenMuWebWeb.ConnCase

  test "GET /info", %{conn: conn} do
    html = conn |> get(~p"/info") |> html_response(200)
    assert html =~ "Server Information"
    assert html =~ "Season: 6 Episode 3"
    assert html =~ "/images/img-util.jpg"
  end

  test "GET /download shows only configured download links", %{conn: conn} do
    html = conn |> get(~p"/download") |> html_response(200)
    assert html =~ "Client Downloads"
    assert html =~ ~s(href="https://drive.example/client")
    assert html =~ ~s(href="https://mega.example/client")
    # mediafire_link is "" in the test settings -> hidden
    refute html =~ "mediafire.png"
    assert html =~ "Recomendend Requirements"
  end

  test "GET /terms-and-conditions", %{conn: conn} do
    html = conn |> get(~p"/terms-and-conditions") |> html_response(200)
    assert html =~ "Terms and Conditions"
    assert html =~ "Welcome to Website Name!"
  end

  test "sidebar shows ranking data and the offline state when the game server is down", %{
    conn: conn
  } do
    OpenMuWeb.Fixtures.stub_game_server_down()
    html = conn |> get(~p"/info") |> html_response(200)
    assert html =~ "/images/offline.png"
    assert html =~ "/images/avatars/"
  end
end
