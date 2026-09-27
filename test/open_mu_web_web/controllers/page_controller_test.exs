defmodule OpenMuWebWeb.PageControllerTest do
  use OpenMuWebWeb.ConnCase

  describe "GET /" do
    test "renders the site layout ported from the Next.js app", %{conn: conn} do
      html = conn |> get(~p"/") |> html_response(200)

      # <head>
      assert html =~ ~r{<title[^>]*>OpenMU Web</title>}
      assert html =~ ~s(content="Created by mamflo")

      # Navbar
      for {label, path} <- [
            {"HOME", "/"},
            {"INFO", "/info"},
            {"RANKING", "/ranking"},
            {"DOWNLOAD", "/download"}
          ] do
        assert html =~ ~s(href="#{path}")
        assert html =~ label
      end

      # Secondary nav + banners
      assert html =~ "/images/download.png"
      assert html =~ "/images/register.png"
      assert html =~ "/images/slider-img-1.jpg"
      assert html =~ "data-banner-next"

      # Login form (anonymous)
      assert html =~ "Account Login"
      assert html =~ "Sign In"
      assert html =~ ~s(href="/recoverpassword")

      # Page content
      assert html =~ "NEWS"

      # Sidebar
      assert html =~ "Server Statistics"
      assert html =~ "/images/online.png"
      assert html =~ "Characters Ranking"
      assert html =~ "Guilds Ranking"

      # Footer
      assert html =~ "© OpenMUWeb"
      assert html =~ ~s(href="/terms-and-conditions")
    end
  end

  describe "static assets" do
    test "serves images copied from the Next.js public/img folder", %{conn: conn} do
      for path <-
            ~w(/images/bg-header.jpg /images/cursor/Cursor.png /images/avatars/dk.jpg /fonts/lora-latin-400.woff2 /favicon.ico) do
        conn = get(build_conn(), path)
        assert conn.status == 200, "expected #{path} to be served"
      end

      _ = conn
    end
  end
end
