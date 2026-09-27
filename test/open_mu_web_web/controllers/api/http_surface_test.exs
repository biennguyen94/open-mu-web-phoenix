defmodule OpenMuWebWeb.Api.HttpSurfaceTest do
  @moduledoc "HTTP-level behaviors reproduced from the Next.js App Router (Phase 6)."
  use OpenMuWebWeb.ConnCase

  describe "wrong methods on existing endpoints" do
    test "405 with an empty body", %{conn: conn} do
      for {method, path} <- [
            {:get, "/api/account/register"},
            {:post, "/api/status"},
            {:patch, "/api/admin/news"},
            {:get, "/api/admin/news/abc"}
          ] do
        conn = dispatch(build_conn(), @endpoint, method, path)
        assert conn.status == 405, "#{method} #{path}"
        assert conn.resp_body == ""
        assert get_resp_header(conn, "content-type") == []
      end

      # HEAD is served as GET (Plug.Head); on a POST-only endpoint it is 405 too
      assert conn |> head("/api/account/register") |> Map.get(:status) == 405
    end

    test "OPTIONS: 204 with the allowed methods", %{conn: conn} do
      cases = %{
        "/api/guilds" => "GET, HEAD, OPTIONS",
        "/api/account/register" => "OPTIONS, POST",
        "/api/admin/news/abc" => "DELETE, OPTIONS",
        "/api/auth/session" => "GET, HEAD, OPTIONS"
      }

      for {path, allow} <- cases do
        conn = options(build_conn(), path)
        assert conn.status == 204
        assert get_resp_header(conn, "allow") == [allow]
      end

      _ = conn
    end
  end

  test "unknown API paths are 404", %{conn: conn} do
    assert get(conn, "/api/nope").status == 404
    assert post(build_conn(), "/api/characters/ranking").status == 404
  end

  test "JSON responses use the same Content-Type as Next.js (no charset)", %{conn: conn} do
    assert conn |> get(~p"/api/guilds") |> get_resp_header("content-type") == ["application/json"]
  end

  describe "trailing slash" do
    test "308 to the path without the slash, query string kept", %{conn: conn} do
      conn = get(conn, "/news/abc/?x=1")
      assert conn.status == 308
      assert get_resp_header(conn, "location") == ["/news/abc?x=1"]
      assert conn.resp_body == "/news/abc?x=1"

      assert build_conn() |> get("/api/guilds/") |> get_resp_header("location") == ["/api/guilds"]
      assert build_conn() |> get("/") |> Map.get(:status) == 200
    end
  end
end
