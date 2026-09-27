defmodule OpenMuWebWeb.Api.RankingController do
  @moduledoc """
  Read-only ranking endpoints (ports of `app/api/characters/ranking/*`):

    * `GET  /api/characters/ranking/reset`   — top 50 characters
    * `GET  /api/characters/ranking/killers` — top 30 killers
    * `POST /api/characters/ranking/online`  — details of the given online players

  Errors: 400 `{"message":"There was a problem try again later"}`.
  """
  use OpenMuWebWeb, :controller

  import OpenMuWebWeb.Api.ApiJSON

  alias OpenMuWeb.Rankings

  @error "There was a problem try again later"

  def reset(conn, _params) do
    rows =
      Enum.map(Rankings.top_characters(50), fn c ->
        object([
          {"CharacterId", c.character_id},
          {"Name", c.name},
          {"CharacterClassId", c.character_class_id},
          {"resets", c.resets},
          {"lvl", c.lvl},
          {"masterlvl", c.masterlvl}
        ])
      end)

    json(conn, rows)
  rescue
    e in [DBConnection.ConnectionError, Postgrex.Error] -> log_and_fail(conn, e)
  end

  def killers(conn, _params) do
    rows =
      Enum.map(Rankings.top_killers(30), fn c ->
        object([
          {"Id", c.id},
          {"CharacterClassId", c.character_class_id},
          {"CurrentMapId", c.current_map_id},
          {"Name", c.name},
          {"PlayerKillCount", c.player_kill_count}
        ])
      end)

    json(conn, rows)
  rescue
    e in [DBConnection.ConnectionError, Postgrex.Error] -> log_and_fail(conn, e)
  end

  @doc """
  Body: the game server status (`{"playersList": [names]}`).

  Deliberate difference (security, decision D1 / R10): the Next.js app returned
  every character (with positions) when `playersList` was missing; here a missing
  or non-string list is rejected with 400, like other invalid bodies already were.
  """
  def online(conn, params) do
    case params["playersList"] do
      names when is_list(names) ->
        if Enum.all?(names, &is_binary/1) do
          rows =
            Enum.map(Rankings.online_players(names), fn c ->
              object([
                {"Name", c.name},
                {"CurrentMapId", c.current_map_id},
                {"CharacterClassId", c.character_class_id},
                {"PositionX", c.position_x},
                {"PositionY", c.position_y}
              ])
            end)

          json(conn, rows)
        else
          send_message(conn, 400, @error)
        end

      _ ->
        send_message(conn, 400, @error)
    end
  rescue
    e in [DBConnection.ConnectionError, Postgrex.Error] -> log_and_fail(conn, e)
  end

  defp log_and_fail(conn, exception) do
    require Logger
    Logger.error("ranking API error: " <> Exception.message(exception))
    send_message(conn, 400, @error)
  end
end
