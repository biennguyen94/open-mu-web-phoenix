defmodule OpenMuWeb.Guilds do
  @moduledoc "Guild rankings and members (read-only)."
  import Ecto.Query

  alias OpenMuWeb.OpenMU.{Character, Guild, GuildMember}
  alias OpenMuWeb.Repo

  @doc "Guilds ordered by score (sidebar: 5, ranking page / API: 30)."
  def top(limit) when is_integer(limit) do
    from(g in Guild, order_by: [desc: g.score], limit: ^limit) |> Repo.all()
  end

  @doc """
  Members of the guild with the given name as `%{name, status}`, in database
  order (the ranking popup reverses it, like the Next.js client).
  """
  def members(guild_name) when is_binary(guild_name) do
    # Same shape as Prisma's `guildMember.findMany({where: {Guild: {Name}}, include: {Character}})`:
    # members are read first (their order is kept), characters are loaded separately.
    guild_ids = from(g in Guild, where: g.name == ^guild_name, select: g.id)

    members =
      from(m in GuildMember, where: m.guild_id in subquery(guild_ids), select: {m.id, m.status})
      |> Repo.all()

    names =
      from(c in Character,
        where: c.id in ^Enum.map(members, &elem(&1, 0)),
        select: {c.id, c.name}
      )
      |> Repo.all()
      |> Map.new()

    Enum.map(members, fn {id, status} -> %{name: Map.fetch!(names, id), status: status} end)
  end

  @doc "Label shown in the member popup (only Guild Master has a label in the Next.js app)."
  def position_label(2), do: "Guild Master"
  def position_label(_), do: ""
end
