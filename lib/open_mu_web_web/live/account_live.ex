defmodule OpenMuWebWeb.AccountLive do
  @moduledoc """
  `/account` — change password (port of `app/account/page.tsx`). Requires login
  (server-side guard, R6). Always changes the password of the logged-in account
  (R1 fixed; the Next.js page also sent a stale login name on first submit).
  """
  use OpenMuWebWeb, :live_view

  alias OpenMuWeb.Accounts

  @empty %{"oldPassword" => "", "newPassword" => "", "repeatNewPassword" => ""}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(@empty, as: :password))}
  end

  @impl true
  def handle_event("change", %{"password" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: :password))}
  end

  def handle_event("save", %{"password" => params}, socket) do
    result =
      Accounts.change_password(
        socket.assigns.current_account,
        params["oldPassword"],
        params["newPassword"],
        params["repeatNewPassword"]
      )

    message = Accounts.change_password_message(result)

    socket =
      if result == :ok,
        do: socket |> put_flash(:info, message) |> assign(form: to_form(@empty, as: :password)),
        else: socket |> put_flash(:error, message) |> assign(form: to_form(params, as: :password))

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} sidebar={@sidebar} current_account={@current_account}>
      <div class="flex flex-col mt-10 items-center w-full">
        <h1 class="font-bold text-2xl text-primary mb-8">Change Password</h1>
        <.form
          for={@form}
          id="password-form"
          class="flex flex-col gap-10 w-56 items-center text-center"
          phx-change="change"
          phx-submit="save"
        >
          <input
            :for={
              {field, placeholder} <- [
                oldPassword: "old password",
                newPassword: "new password",
                repeatNewPassword: "repeat new password"
              ]
            }
            type="password"
            id={Atom.to_string(field)}
            name={@form[field].name}
            value={@form[field].value}
            placeholder={placeholder}
            minlength="8"
            class="text-center bg-inherit border-b-2 border-slate-400 text-lg p-2 outline-none text-primary invalid:border-red-500"
          />
          <button class="bg-secondary/[0.6] px-5 p-3 rounded-xl w-5/6 text-lg text-primary hover:bg-secondary/[0.9]">
            Change Password
          </button>
        </.form>
      </div>
    </Layouts.app>
    """
  end
end
