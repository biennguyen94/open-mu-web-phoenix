defmodule OpenMuWebWeb.Api.AuthController do
  @moduledoc """
  `GET /api/auth/session` — same JSON as NextAuth's session endpoint:
  `{"user":{"email","username","role"},"expires"}` when logged in, `{}` otherwise.

  The NextAuth sign-in/sign-out protocol endpoints (`/api/auth/csrf`,
  `/api/auth/callback/credentials`, `/api/auth/signout`, ...) are library-specific
  and replaced by `POST /login` / `DELETE /logout` (documented in docs/AUTH.md).
  """
  use OpenMuWebWeb, :controller

  import OpenMuWebWeb.Api.ApiJSON

  alias OpenMuWeb.Accounts.CurrentAccount

  @session_days 30

  def session(conn, _params) do
    case conn.assigns[:current_account] do
      nil ->
        json(conn, object([]))

      account ->
        expires =
          DateTime.utc_now()
          |> DateTime.add(@session_days, :day)
          |> DateTime.truncate(:millisecond)
          |> DateTime.to_iso8601()

        json(
          conn,
          object([
            {"user",
             object([
               {"email", account.email},
               {"username", account.login_name},
               {"role", CurrentAccount.role(account)}
             ])},
            {"expires", expires}
          ])
        )
    end
  end
end
