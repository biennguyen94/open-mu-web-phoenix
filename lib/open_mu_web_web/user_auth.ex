defmodule OpenMuWebWeb.UserAuth do
  @moduledoc """
  Session-based authentication (replaces NextAuth credentials + JWT).

  * The session cookie (signed and encrypted, 30 days like NextAuth's default)
    stores only `"account_id"`.
  * The account and its Game Master flag are loaded from the database on every
    request (`:current_account`), so roles are never stale.
  * Plugs `fetch_current_account/2`, `require_authenticated/2`, `require_gm/2` and
    LiveView hooks `:mount_current_account`, `:require_authenticated`, `:require_gm`.
  * The session is renewed on login (no fixation) and dropped on logout.
  """
  use OpenMuWebWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias OpenMuWeb.Accounts

  @forbidden_message "You can't do this!"

  @doc "Logs the account in: renews the session and stores its id."
  def log_in(conn, %Accounts.CurrentAccount{id: id}) do
    conn
    |> renew_session()
    |> put_session(:account_id, id)
  end

  @doc "Logs out: drops the whole session."
  def log_out(conn) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      OpenMuWebWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    renew_session(conn)
  end

  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  ## Plugs

  def fetch_current_account(conn, _opts) do
    account_id = get_session(conn, :account_id)
    account = Accounts.get_current_account(account_id)

    conn =
      if account_id && is_nil(account), do: delete_session(conn, :account_id), else: conn

    assign(conn, :current_account, account)
  end

  def require_authenticated(conn, _opts) do
    if conn.assigns[:current_account], do: conn, else: deny(conn)
  end

  def require_gm(conn, _opts) do
    case conn.assigns[:current_account] do
      %{gm?: true} -> conn
      _ -> deny(conn)
    end
  end

  defp deny(conn) do
    conn
    |> put_flash(:error, @forbidden_message)
    |> redirect(to: ~p"/")
    |> halt()
  end

  ## LiveView hooks

  def on_mount(:mount_current_account, _params, session, socket) do
    {:cont, mount_current_account(socket, session)}
  end

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_account(socket, session)

    if socket.assigns.current_account,
      do: {:cont, socket},
      else: {:halt, deny_live(socket)}
  end

  def on_mount(:require_gm, _params, session, socket) do
    socket = mount_current_account(socket, session)

    case socket.assigns.current_account do
      %{gm?: true} -> {:cont, socket}
      _ -> {:halt, deny_live(socket)}
    end
  end

  defp mount_current_account(socket, session) do
    Phoenix.Component.assign_new(socket, :current_account, fn ->
      Accounts.get_current_account(session["account_id"])
    end)
  end

  defp deny_live(socket) do
    socket
    |> Phoenix.LiveView.put_flash(:error, @forbidden_message)
    |> Phoenix.LiveView.redirect(to: ~p"/")
  end

  @doc """
  Local path to go back to after login/logout (the Next.js app refreshed the
  current page). Only same-site relative paths from the Referer are accepted.
  """
  def return_path(conn) do
    with [referer | _] <- get_req_header(conn, "referer"),
         %URI{path: "/" <> _ = path, query: query, host: host} <- URI.parse(referer),
         true <- host in [nil, conn.host],
         false <- String.starts_with?(path, "//") do
      if query, do: path <> "?" <> query, else: path
    else
      _ -> ~p"/"
    end
  end
end
