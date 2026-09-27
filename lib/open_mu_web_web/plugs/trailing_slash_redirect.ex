defmodule OpenMuWebWeb.Plugs.TrailingSlashRedirect do
  @moduledoc """
  Next.js (`trailingSlash: false`) answers `/path/` with `308 Permanent Redirect`
  to `/path` (query string kept, the target also written as the body). Reproduced
  here for every path so links and API clients behave the same.
  """
  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{request_path: path} = conn, _opts) when path != "/" do
    if String.ends_with?(path, "/") do
      location = String.trim_trailing(path, "/")
      location = if location == "", do: "/", else: location

      location =
        if conn.query_string == "", do: location, else: location <> "?" <> conn.query_string

      conn
      |> put_resp_header("location", location)
      |> send_resp(308, location)
      |> halt()
    else
      conn
    end
  end

  def call(conn, _opts), do: conn
end
