defmodule OpenMuWebWeb.Sidebar do
  @moduledoc """
  Loads the sidebar shown on every page (server statistics, top 10 characters,
  top 5 guilds) — the data the Next.js layout rendered on each request.

  Used as a plug in the `:browser` pipeline and as a LiveView `on_mount` hook;
  templates pass `@sidebar` to `<Layouts.app>`.
  """
  import Plug.Conn, only: [assign: 3]

  alias OpenMuWeb.{GameServer, Guilds, Rankings}

  @doc "Sidebar data map for `Layouts.app`."
  def load do
    %{
      server_status: server_status(),
      top_characters: Rankings.top_characters(10),
      top_guilds: Guilds.top(5)
    }
  end

  @doc "Plug: assigns `:sidebar`."
  def assign_sidebar(conn, _opts), do: assign(conn, :sidebar, load())

  @doc "LiveView hook: assigns `:sidebar`."
  def on_mount(:default, _params, _session, socket) do
    {:cont, Phoenix.Component.assign(socket, :sidebar, load())}
  end

  # ServerStatistics.tsx shows the game server response when /api/status is ok and
  # nothing otherwise ("offline", 0 players).
  defp server_status do
    case GameServer.cached_status() do
      {:ok, status} -> %{state: status["state"], players: status["players"]}
      {:error, _} -> nil
    end
  end
end
