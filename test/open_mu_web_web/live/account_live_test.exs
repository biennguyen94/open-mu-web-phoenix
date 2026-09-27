defmodule OpenMuWebWeb.AccountLiveTest do
  use OpenMuWebWeb.ConnCase

  import Phoenix.LiveViewTest

  test "requires login (server-side guard)", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/", flash: %{"error" => "You can't do this!"}}}} =
             live(conn, ~p"/account")

    assert conn |> get(~p"/account") |> redirected_to() == "/"
  end

  test "changes the password of the logged-in account", %{conn: conn} do
    {:ok, view, html} = conn |> log_in("test1") |> live(~p"/account")
    assert html =~ "Change Password"
    assert html =~ ~s(href="/logout")

    html =
      view
      |> form("#password-form",
        password: %{
          oldPassword: "test1",
          newPassword: "password2",
          repeatNewPassword: "password2"
        }
      )
      |> render_submit()

    assert html =~ "Password changes successfully"
    assert {:ok, _} = OpenMuWeb.Accounts.authenticate("test1", "password2")
  end

  test "shows the error message", %{conn: conn} do
    {:ok, view, _html} = conn |> log_in("test1") |> live(~p"/account")

    html =
      view
      |> form("#password-form",
        password: %{
          oldPassword: "wrong",
          newPassword: "password2",
          repeatNewPassword: "password2"
        }
      )
      |> render_submit()

    assert html =~ "The old password you inserted isn&#39;t correct!"
  end
end
