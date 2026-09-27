defmodule OpenMuWeb.GameServer do
  @moduledoc """
  Client for the OpenMU admin panel status endpoint (`GAMESERVER_URL/api/status`).

  OpenMU answers `{"state":"Online","players":N,"playersList":[names]}` with
  `Content-Type: text/plain` (VERIFIED, `ServerController.ServerState` serializes a
  string), so the body is decoded explicitly. Key order is preserved so that
  `/api/status` can relay the payload unchanged, like the Next.js app.

  * `status/0` always calls the game server (used by `/api/status`, the online
    ranking and — in Phase 4 — the "character is online" checks).
  * `cached_status/0` caches the result for `cache_ttl_ms` (sidebar on every page).
  """

  alias OpenMuWeb.GameServer.Cache
  alias OpenMuWeb.Settings

  @type status :: Jason.OrderedObject.t()
  @type error :: {:http_status, pos_integer()} | :unreachable | :invalid_body | :not_configured

  @doc "Fetches the current status. Returns `{:ok, ordered_map}` or `{:error, reason}`."
  @spec status() :: {:ok, status()} | {:error, error()}
  def status do
    case Settings.game_server_url() do
      nil -> {:error, :not_configured}
      base_url -> fetch(base_url)
    end
  end

  @doc "Like `status/0`, but served from a short-lived cache."
  def cached_status do
    Cache.fetch(:status, cache_ttl_ms(), &status/0)
  end

  @doc "Names of the players currently online (empty list when unknown)."
  def players_list({:ok, status}), do: players_list(status)

  def players_list(%Jason.OrderedObject{} = status) do
    case status["playersList"] do
      list when is_list(list) -> list
      _ -> []
    end
  end

  def players_list(_), do: []

  defp fetch(base_url) do
    options =
      [url: String.trim_trailing(base_url, "/") <> "/api/status", decode_body: false]
      |> Keyword.merge(config(:req_options, []))

    case Req.get(options) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        decode(body)

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_status, status}}

      {:error, _exception} ->
        {:error, :unreachable}
    end
  end

  defp decode(body) when is_binary(body) do
    case Jason.decode(body, objects: :ordered_objects) do
      {:ok, %Jason.OrderedObject{} = status} -> {:ok, status}
      _ -> {:error, :invalid_body}
    end
  end

  defp decode(_), do: {:error, :invalid_body}

  defp cache_ttl_ms, do: config(:cache_ttl_ms, 5_000)

  defp config(key, default) do
    :open_mu_web |> Application.get_env(__MODULE__, []) |> Keyword.get(key, default)
  end
end
