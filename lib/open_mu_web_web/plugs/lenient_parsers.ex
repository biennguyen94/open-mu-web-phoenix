defmodule OpenMuWebWeb.Plugs.LenientParsers do
  @moduledoc """
  Request body parsing with the semantics of the Next.js route handlers on `/api/*`.

  The Next.js handlers called `req.json()` inside their own `try`, which:

    * parses the body as JSON **whatever the Content-Type is** (the Next.js admin
      news form even sent it as `text/plain`), and
    * throws on an empty or malformed body, which each route turned into its
      usual error JSON (e.g. register → 500 `{"message":"Something went wrong!","error":{}}`).

  So for `/api/*` requests with a body method (POST/PUT/PATCH/DELETE) the body is
  decoded as JSON here; on failure `conn.private[:body_parse_error]` is set and
  the params stay empty, letting each controller answer like its Next.js
  counterpart. A JSON value that is not an object ends up under `"_json"` (the
  Plug convention). Everything else goes through the regular `Plug.Parsers`.
  """
  @behaviour Plug

  @body_methods ~w(POST PUT PATCH DELETE)
  @max_length 1_000_000

  @impl true
  def init(opts), do: Plug.Parsers.init(opts)

  @impl true
  # Body params already set (e.g. by Plug.Test with a params map): nothing to parse,
  # exactly like Plug.Parsers.
  def call(
        %Plug.Conn{body_params: %Plug.Conn.Unfetched{}, path_info: ["api" | _], method: method} =
          conn,
        _opts
      )
      when method in @body_methods do
    conn = Plug.Conn.fetch_query_params(conn)

    case read_json(conn) do
      {:ok, body_params, conn} ->
        %{conn | body_params: body_params, params: Map.merge(conn.query_params, body_params)}

      {:error, conn} ->
        %{conn | body_params: %{}, params: conn.query_params}
        |> Plug.Conn.put_private(:body_parse_error, true)
    end
  end

  def call(conn, opts), do: Plug.Parsers.call(conn, opts)

  defp read_json(conn) do
    case Plug.Conn.read_body(conn, length: @max_length) do
      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, %{} = map} -> {:ok, map, conn}
          {:ok, other} -> {:ok, %{"_json" => other}, conn}
          {:error, _} -> {:error, conn}
        end

      {:more, _partial, conn} ->
        {:error, conn}

      {:error, _reason} ->
        {:error, conn}
    end
  end
end
