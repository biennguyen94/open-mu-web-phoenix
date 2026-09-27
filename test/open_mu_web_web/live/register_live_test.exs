defmodule OpenMuWebWeb.RegisterLiveTest do
  use OpenMuWebWeb.ConnCase

  import Phoenix.LiveViewTest

  @params %{
    username: "liveuser1",
    email: "liveuser1@example.com",
    password: "password1",
    repeat_password: "password1"
  }

  test "button is disabled until the terms are accepted", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/register")
    assert html =~ "Registration"
    assert has_element?(view, "button[type=submit][disabled]")

    view |> form("#register-form", register: @params, terms: "on") |> render_change()
    refute has_element?(view, "button[type=submit][disabled]")
  end

  test "registers the account", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/register")
    html = view |> form("#register-form", register: @params, terms: "on") |> render_submit()

    assert html =~ "User created succesfully!"
    assert {:ok, _} = OpenMuWeb.Accounts.authenticate("liveuser1", "password1")
  end

  test "error toasts", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/register")

    assert view
           |> form("#register-form",
             register: %{@params | repeat_password: "other123"},
             terms: "on"
           )
           |> render_submit() =~
             "The passwords must coincide"

    assert view
           |> form("#register-form", register: %{@params | username: "test1"}, terms: "on")
           |> render_submit() =~
             "Username already in use!"

    # B1 fixed: validation failures are shown as an error (Next.js showed a success toast)
    html =
      view
      |> form("#register-form", register: %{@params | username: "ab"}, terms: "on")
      |> render_submit()

    assert html =~ "Something went wrong!"
    assert html =~ "border-red-500"
  end
end
