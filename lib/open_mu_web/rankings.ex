defmodule OpenMuWeb.Rankings do
  @moduledoc """
  Rankings (read-only). Ports of the raw SQL / Prisma queries of the Next.js app,
  see `docs/DATABASE.md` §4. Output values are normalized with `OpenMuWeb.Float32`.
  """
  import Ecto.Query

  alias OpenMuWeb.Float32
  alias OpenMuWeb.OpenMU.{Character, Ids, StatAttribute}
  alias OpenMuWeb.Repo

  @doc """
  Characters ordered by resets, level, master level (sidebar: 10, ranking page: 50).

  Same SQL as the Next.js app: pivot of `StatAttribute` with `MAX(CASE ... ELSE 0)`,
  grouped by character, GM characters included.
  """
  def top_characters(limit) when is_integer(limit) do
    resets = Ids.resets()
    level = Ids.level()
    master_level = Ids.master_level()

    from(sa in StatAttribute,
      join: c in Character,
      on: sa.character_id == c.id,
      group_by: [sa.character_id, c.name, c.character_class_id],
      select: %{
        character_id: sa.character_id,
        name: c.name,
        character_class_id: c.character_class_id,
        resets:
          selected_as(
            fragment(
              "MAX(CASE WHEN ? = ? THEN ? ELSE 0 END)",
              sa.definition_id,
              type(^resets, Ecto.UUID),
              sa.value
            ),
            :resets
          ),
        lvl:
          selected_as(
            fragment(
              "MAX(CASE WHEN ? = ? THEN ? ELSE 0 END)",
              sa.definition_id,
              type(^level, Ecto.UUID),
              sa.value
            ),
            :lvl
          ),
        masterlvl:
          selected_as(
            fragment(
              "MAX(CASE WHEN ? = ? THEN ? ELSE 0 END)",
              sa.definition_id,
              type(^master_level, Ecto.UUID),
              sa.value
            ),
            :masterlvl
          )
      },
      order_by: [
        desc: selected_as(:resets),
        desc: selected_as(:lvl),
        desc: selected_as(:masterlvl)
      ],
      limit: ^limit
    )
    |> Repo.all()
    |> Enum.map(fn row ->
      %{
        row
        | resets: Float32.normalize(row.resets),
          lvl: Float32.normalize(row.lvl),
          masterlvl: Float32.normalize(row.masterlvl)
      }
    end)
  end

  @doc "Top player killers (top 30 on the ranking page)."
  def top_killers(limit \\ 30) when is_integer(limit) do
    from(c in Character,
      order_by: [desc: c.player_kill_count],
      limit: ^limit,
      select: %{
        id: c.id,
        character_class_id: c.character_class_id,
        current_map_id: c.current_map_id,
        name: c.name,
        player_kill_count: c.player_kill_count
      }
    )
    |> Repo.all()
  end

  @doc """
  Characters whose name is in `names` (the game server `playersList`), with map
  and position. Order is the database order, like the Next.js app.
  """
  def online_players([]), do: []

  def online_players(names) when is_list(names) do
    from(c in Character,
      where: c.name in ^names,
      select: %{
        name: c.name,
        current_map_id: c.current_map_id,
        character_class_id: c.character_class_id,
        position_x: c.position_x,
        position_y: c.position_y
      }
    )
    |> Repo.all()
  end
end
