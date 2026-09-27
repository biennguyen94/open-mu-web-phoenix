defmodule OpenMuWebWeb.SessionControllerTest do
  use OpenMuWebWeb.ConnCase

  describe "POST /login" do
    test "logs in, renews the session and returns to the referring page", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{"other" => "value"})
        |> put_req_header("referer", "http://www.example.com/info")
        |> post(~p"/login", %{"username" => "test1", "password" => "test1"})

      assert redirected_to(conn) == "/info"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Welcome back test1"
      assert get_session(conn, "account_id")
      refute get_session(conn, "other")

      html = conn |> recycle() |> get(~p"/info") |> html_response(200)
      assert html =~ ~s(href="/account")
      assert html =~ ~s(href="/characters")
      refute html =~ ~s(href="/admin/news")
      refute html =~ "Account Login"
    end

    test "Game Masters get the News link", %{conn: conn} do
      conn = post(conn, ~p"/login", %{"username" => "testgm", "password" => "testgm"})
      assert conn |> recycle() |> get(~p"/") |> html_response(200) =~ ~s(href="/admin/news")
    end

    test "wrong credentials", %{conn: conn} do
      conn = post(conn, ~p"/login", %{"username" => "test1", "password" => "nope"})
      assert redirected_to(conn) == "/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == " Invalid Username or Password"
      refute get_session(conn, "account_id")
    end

    test "external referers are ignored", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "https://evil.example/phish")
        |> post(~p"/login", %{"username" => "test1", "password" => "test1"})

      assert redirected_to(conn) == "/"
    end

    test "requires the CSRF token (browser pipeline)" do
      conn =
        build_conn()
        |> Plug.Conn.put_private(:plug_skip_csrf_protection, false)
        |> init_test_session(%{})

      assert_raise Plug.CSRFProtection.InvalidCSRFTokenError, fn ->
        post(conn, ~p"/login", %{"username" => "test1", "password" => "test1"})
      end
    end
  end

  test "DELETE /logout drops the session", %{conn: conn} do
    conn =
      conn
      |> log_in("test1")
      |> put_req_header("referer", "http://www.example.com/ranking")
      |> delete(~p"/logout")

    assert redirected_to(conn) == "/ranking"
    refute get_session(conn, "account_id")
  end

  test "a session pointing to a deleted account is treated as anonymous", %{conn: conn} do
    conn = conn |> init_test_session(%{"account_id" => Ecto.UUID.generate()}) |> get(~p"/info")
    assert html_response(conn, 200) =~ "Account Login"
    refute get_session(conn, "account_id")
  end
end
