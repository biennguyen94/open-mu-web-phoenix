defmodule OpenMuWebWeb.Api.GuildController do
  @moduledoc """
  Guild endpoints (ports of `app/api/guilds/*`):

    * `GET /api/guilds`              — top 30 guilds by score, every column
      (`Logo` serialized like Prisma `Bytes`)
    * `GET /api/guilds/:guild_name`  — `[{"Name","guildStatus"}]`; unknown or
      empty guild → 400 `{"messasge":"Guild wasn't found"}` (key typo kept for parity)
  """
  use OpenMuWebWeb, :controller

  import OpenMuWebWeb.Api.ApiJSON

  alias OpenMuWeb.Guilds

  def index(conn, _params) do
    rows =
      Enum.map(Guilds.top(30), fn g ->
        object([
          {"Id", g.id},
          {"HostilityId", g.hostility_id},
          {"AllianceGuildId", g.alliance_guild_id},
          {"Name", g.name},
          {"Logo", bytes(g.logo)},
          {"Score", g.score},
          {"Notice", g.notice}
        ])
      end)

    json(conn, rows)
  end

  def show(conn, %{"guild_name" => guild_name}) do
    case Guilds.members(guild_name) do
      [] ->
        send_json(conn, 400, object([{"messasge", "Guild wasn't found"}]))

      members ->
        json(conn, Enum.map(members, &object([{"Name", &1.name}, {"guildStatus", &1.status}])))
    end
  rescue
    _ in [DBConnection.ConnectionError, Postgrex.Error] ->
      send_message(conn, 400, "Guild wasn't found")
  end
end
