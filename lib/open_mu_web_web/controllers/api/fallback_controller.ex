defmodule OpenMuWebWeb.Api.FallbackController do
  @moduledoc """
  Catch-all for `/api/*` requests that match no route, reproducing the Next.js
  App Router responses:

    * `OPTIONS` on an existing endpoint → `204` with `allow:` listing its methods
      (plus `HEAD` for GET routes and `OPTIONS`, alphabetically), empty body;
    * another method on an existing endpoint → `405`, empty body;
    * unknown path → the regular 404.

  The allowed methods are derived from the router itself, so they cannot drift
  from the real routes.
  """
  use OpenMuWebWeb, :controller

  @methods ~w(GET POST PUT PATCH DELETE)

  def call(conn, _params) do
    case allowed_methods(conn) do
      [] ->
        raise Phoenix.Router.NoRouteError, conn: conn, router: OpenMuWebWeb.Router

      allowed ->
        conn = delete_resp_header(conn, "content-type")

        if conn.method == "OPTIONS" do
          extra = if "GET" in allowed, do: ["HEAD", "OPTIONS"], else: ["OPTIONS"]

          conn
          |> put_resp_header("allow", (allowed ++ extra) |> Enum.sort() |> Enum.join(", "))
          |> send_resp(204, "")
        else
          send_resp(conn, 405, "")
        end
    end
  end

  defp allowed_methods(conn) do
    Enum.filter(@methods, fn method ->
      case Phoenix.Router.route_info(OpenMuWebWeb.Router, method, conn.request_path, conn.host) do
        %{plug: plug} -> plug != __MODULE__
        :error -> false
      end
    end)
  end
end
