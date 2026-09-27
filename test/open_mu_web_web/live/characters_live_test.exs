defmodule OpenMuWebWeb.CharactersLiveTest do
  use OpenMuWebWeb.ConnCase

  import Phoenix.LiveViewTest
  import OpenMuWeb.Fixtures

  alias OpenMuWeb.OpenMU.Ids

  test "requires login", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/characters")
  end

  test "lists the account's characters with their stats and buttons", %{conn: conn} do
    {:ok, view, html} = conn |> log_in("test1") |> live(~p"/characters")

    for name <- ~w(test1Dk test1Dl test1Dw test1Elf), do: assert(html =~ name)
    refute has_element?(view, "#character-test400Dk")
    assert has_element?(view, "#character-test1Dk p", "Lvl:")
    assert has_element?(view, "#character-test1Dk span", "11")
    assert has_element?(view, "#character-test1Dk button[phx-click=reset]")
    assert has_element?(view, "#character-test1Dk button", "Pk Clear")
    assert has_element?(view, "#character-test1Dk img[src='/images/avatars/dk.jpg']")
  end

  test "accounts without characters", %{conn: conn} do
    {:ok, _view, html} = conn |> log_in("testunlock") |> live(~p"/characters")
    assert html =~ "There are no created characters at the moment"
  end

  test "add stats card: toggle, leadership only for Dark Lords, add points", %{conn: conn} do
    {:ok, view, _html} = conn |> log_in("test1") |> live(~p"/characters")

    view |> element("#character-test1Dl button", "Add Stats") |> render_click()
    assert has_element?(view, "#add-stats-form p", "Leadership:")

    view |> element("#character-test1Dk button", "Add Stats") |> render_click()
    refute has_element?(view, "#add-stats-form p", "Leadership:")
    assert has_element?(view, "#add-stats-form p", "Free Points: 50")

    html =
      view
      |> form("#add-stats-form", amounts: %{str: "5", agi: "", vit: "0", ene: "2"})
      |> render_submit()

    assert html =~ "Character points added succesfuly"
    assert has_element?(view, "#add-stats-form p", "Free Points: 43")
    assert stat("test1Dk", Ids.strength()) == 33.0

    html = view |> form("#add-stats-form", amounts: %{str: "-5"}) |> render_submit()
    assert html =~ "There was a problem try again later"

    view |> element("#character-test1Dk button", "Add Stats") |> render_click()
    refute has_element?(view, "#add-stats-form")
  end

  test "reset / pk clear / reset stats buttons", %{conn: conn} do
    {:ok, view, _html} = conn |> log_in("test400") |> live(~p"/characters")

    assert view |> element("#character-test400Elf button[phx-click=reset]") |> render_click() =~
             "Character reseted successfully!"

    assert has_element?(view, "#character-test400Elf span", "1")

    assert view |> element("#character-test400Elf button[phx-click=reset]") |> render_click() =~
             "You aren&#39;t lvl 400"

    assert view |> element("#character-test400Dk button", "Pk Clear") |> render_click() =~
             "PkClear successfully"

    assert view |> element("#character-test400Dw button", "Reset Stats") |> render_click() =~
             "Points were reseted succesffuly"
  end
end
