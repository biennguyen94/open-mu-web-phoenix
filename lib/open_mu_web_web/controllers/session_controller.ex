defmodule OpenMuWebWeb.SessionController do
  @moduledoc """
  Login / logout for the forms in the layout (`LoginForm.tsx`, `UserPanel.tsx`).
  Messages are the Next.js toasts; the browser returns to the page it came from.
  """
  use OpenMuWebWeb, :controller

  alias OpenMuWeb.Accounts
  alias OpenMuWebWeb.UserAuth

  def create(conn, params) do
    username = params["username"]
    return_to = UserAuth.return_path(conn)

    case Accounts.authenticate(username, params["password"]) do
      {:ok, account} ->
        conn
        |> UserAuth.log_in(account)
        |> put_flash(:info, "Welcome back " <> username)
        |> redirect(to: return_to)

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, " Invalid Username or Password")
        |> redirect(to: return_to)
    end
  end

  def delete(conn, _params) do
    return_to = UserAuth.return_path(conn)

    conn
    |> UserAuth.log_out()
    |> redirect(to: return_to)
  end
end
