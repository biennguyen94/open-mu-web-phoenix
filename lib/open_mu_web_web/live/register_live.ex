defmodule OpenMuWebWeb.RegisterLive do
  @moduledoc """
  `/register` — port of `app/register/page.tsx`. The Register button stays
  disabled until the Terms checkbox is ticked; passwords are compared before
  submitting ("The passwords must coincide"), then `OpenMuWeb.Accounts.register/1`
  is called (the same code as `POST /api/account/register`).

  Difference (bug B1 fixed): validation failures show an error toast
  ("Something went wrong!") instead of the success-styled toast of the Next.js page.
  """
  use OpenMuWebWeb, :live_view

  alias OpenMuWeb.Accounts

  @empty %{"username" => "", "email" => "", "password" => "", "repeat_password" => ""}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(@empty, as: :register), accepted: false)}
  end

  @impl true
  def handle_event("change", %{"register" => params} = all, socket) do
    {:noreply,
     assign(socket, form: to_form(params, as: :register), accepted: all["terms"] == "on")}
  end

  def handle_event("register", %{"register" => params} = all, socket) do
    cond do
      all["terms"] != "on" ->
        {:noreply, socket}

      params["password"] != params["repeat_password"] ->
        {:noreply, put_flash(socket, :error, "The passwords must coincide")}

      true ->
        payload = %{
          "LoginName" => params["username"],
          "EMail" => params["email"],
          "Password" => params["password"],
          "RepeatPassword" => params["repeat_password"]
        }

        case Accounts.register(payload) do
          {:ok, _account} ->
            {:noreply,
             socket
             |> put_flash(:info, "User created succesfully!")
             |> assign(form: to_form(@empty, as: :register))}

          {:error, :email_taken} ->
            {:noreply,
             socket
             |> put_flash(:error, "Email already in use!")
             |> assign(form: to_form(params, as: :register))}

          {:error, :username_taken} ->
            {:noreply,
             socket
             |> put_flash(:error, "Username already in use!")
             |> assign(form: to_form(params, as: :register))}

          {:error, _} ->
            {:noreply,
             socket
             |> put_flash(:error, "Something went wrong!")
             |> assign(form: to_form(params, as: :register))}
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} sidebar={@sidebar} current_account={@current_account}>
      <div class="flex items-center flex-col text-center mx-auto mt-10 w-full">
        <h2 class="text-2xl font-semibold text-primary mb-8">Registration</h2>
        <.form for={@form} id="register-form" class="w-72" phx-change="change" phx-submit="register">
          <input
            type="text"
            name={@form[:username].name}
            value={@form[:username].value}
            placeholder="username"
            minlength="4"
            class="border-b-2 p-2 invalid:border-red-500 border-slate-400 outline-none bg-inherit text-lg text-center mb-2 text-primary"
          />
          <input
            type="email"
            name={@form[:email].name}
            value={@form[:email].value}
            placeholder="email"
            minlength="8"
            class="mt-6 border-b-2 p-2 invalid:border-red-500 border-slate-400 outline-none bg-inherit text-lg text-center mb-2 text-primary"
          />
          <input
            type="password"
            name={@form[:password].name}
            value={@form[:password].value}
            placeholder="password"
            minlength="8"
            class="mt-6 border-b-2 p-2 invalid:border-red-500 border-slate-400 outline-none bg-inherit text-lg text-center mb-2 text-primary"
          />
          <input
            type="password"
            name={@form[:repeat_password].name}
            value={@form[:repeat_password].value}
            placeholder="repeat password"
            minlength="8"
            class="mt-6 border-b-2 p-2 invalid:border-red-500 border-slate-400 outline-none bg-inherit text-lg text-center mb-8 text-primary"
          />
          <label for="terms" class="text-primary inline-block">
            <input
              type="checkbox"
              id="terms"
              name="terms"
              checked={@accepted}
              class="w-4 h-4 bg-gray-100 rounded-md focus:ring-blue-400 focus:ring-2"
            /> Accept
            <.link href={~p"/terms-and-conditions"} class="italic text-primary">Terms and Conditions</.link>
          </label>
          <button
            type="submit"
            disabled={!@accepted}
            class="mt-8 bg-secondary/[0.6] disabled:bg-slate-300/[0.9] hover:bg-secondary/[0.9] p-3 rounded-lg text-primary w-44 mx-auto shadow-xl text-xl"
          >
            Register
          </button>
        </.form>
      </div>
    </Layouts.app>
    """
  end
end
