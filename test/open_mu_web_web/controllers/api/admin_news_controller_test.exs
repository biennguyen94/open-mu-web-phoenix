defmodule OpenMuWebWeb.Api.AdminNewsControllerTest do
  use OpenMuWebWeb.ConnCase

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.News.Article

  defp message(conn, status), do: json_response(conn, status)["message"]

  test "GM creates news, also with a text/plain JSON body", %{conn: conn} do
    conn = log_in(conn, "testgm")

    assert conn |> post(~p"/api/admin/news", %{"title" => "t", "body" => "b"}) |> message(200) ==
             "News added successfully"

    assert conn
           |> put_req_header("content-type", "text/plain;charset=UTF-8")
           |> post(~p"/api/admin/news", ~s({"title":"t2","body":"b2"}))
           |> message(200) == "News added successfully"

    assert OpenMuWeb.Repo.get_by!(Article, title: "t2").author == "testgmDk"
  end

  test "errors", %{conn: conn} do
    assert conn |> post(~p"/api/admin/news", %{"title" => "t", "body" => "b"}) |> message(500) ==
             "You can't do this!"

    assert build_conn()
           |> log_in("test1")
           |> post(~p"/api/admin/news", %{"title" => "t", "body" => "b"})
           |> message(500) == "You can't do this!"

    gm = build_conn() |> log_in("testgm")

    assert gm |> post(~p"/api/admin/news", %{"title" => "t"}) |> message(400) ==
             "There was a problem try again later"

    # body read before the session check, like req.json() in the Next.js route
    assert build_conn()
           |> put_req_header("content-type", "application/json")
           |> post(~p"/api/admin/news", "nojson")
           |> message(400) == "There was a problem try again later"
  end

  test "delete", %{conn: conn} do
    article = insert_news!(title: "x")
    gm = log_in(conn, "testgm")

    assert build_conn()
           |> log_in("test1")
           |> delete(~p"/api/admin/news/#{article.id}")
           |> message(500) == "You can't do this!"

    assert gm |> delete(~p"/api/admin/news/#{article.id}") |> message(200) ==
             "News deleted successfully"

    assert gm |> delete(~p"/api/admin/news/#{article.id}") |> message(400) ==
             "There was a problem try again later"

    assert gm |> delete(~p"/api/admin/news/not-a-uuid") |> message(400) ==
             "There was a problem try again later"
  end
end
