defmodule OpenMuWebWeb.Api.StatusController do
  @moduledoc """
  `GET /api/status` — relays the OpenMU status (port of `app/api/status/route.ts`):
  201 with the game server JSON; 500 when the game server answers non-2xx or
  cannot be reached / parsed.
  """
  use OpenMuWebWeb, :controller

  import OpenMuWebWeb.Api.ApiJSON

  alias OpenMuWeb.GameServer

  def show(conn, _params) do
    case GameServer.status() do
      {:ok, status} -> send_json(conn, 201, status)
      {:error, {:http_status, _}} -> send_message(conn, 500, "Couldn't connect to the gameserver")
      {:error, _} -> send_message(conn, 500, "There was an error")
    end
  end
end
