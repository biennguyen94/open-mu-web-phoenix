defmodule OpenMuWebWeb.AdminNewsControllerTest do
  use OpenMuWebWeb.ConnCase

  import OpenMuWeb.Fixtures

  setup do
    delete_all_news!()
    %{article: insert_news!(title: "Hello", body: "World")}
  end

  test "GMs see the Delete button and the confirmation dialog", %{conn: conn, article: article} do
    html = conn |> log_in("testgm") |> get(~p"/") |> html_response(200)
    assert html =~ ~s(data-news-delete="news-delete-#{article.id}")
    assert html =~ "Are you sure you want to delete this news?"
    assert html =~ ~s(action="/admin/news/#{article.id}")

    assert html =~
             ~r/<input[^>]*(name="_method"[^>]*value="delete"|value="delete"[^>]*name="_method")/

    detail =
      build_conn() |> log_in("testgm") |> get(~p"/news/#{article.id}") |> html_response(200)

    assert detail =~ "data-news-delete"
  end

  test "other visitors do not", %{conn: conn} do
    refute conn |> get(~p"/") |> html_response(200) =~ "data-news-delete"

    refute build_conn() |> log_in("test1") |> get(~p"/") |> html_response(200) =~
             "data-news-delete"
  end

  test "DELETE /admin/news/:id as GM returns to the page with a toast", %{
    conn: conn,
    article: article
  } do
    conn =
      conn
      |> log_in("testgm")
      |> put_req_header("referer", "http://www.example.com/?page=0")
      |> delete(~p"/admin/news/#{article.id}")

    assert redirected_to(conn) == "/?page=0"
    assert Phoenix.Flash.get(conn.assigns.flash, :info) == "News deleted successfully"
    assert OpenMuWeb.News.get_article(article.id) == nil

    conn = build_conn() |> log_in("testgm") |> delete(~p"/admin/news/#{article.id}")
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "There was a problem try again later"
  end

  test "non-GM accounts are refused (require_gm)", %{conn: conn, article: article} do
    conn = conn |> log_in("test1") |> delete(~p"/admin/news/#{article.id}")
    assert redirected_to(conn) == "/"
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "You can't do this!"
    assert OpenMuWeb.News.get_article(article.id)
  end
end
