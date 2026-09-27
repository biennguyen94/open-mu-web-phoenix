defmodule OpenMuWeb.OpenMU.Guild do
  @moduledoc "`guild.\"Guild\"` (OpenMU-owned)."
  use Ecto.Schema

  @schema_prefix "guild"
  @primary_key {:id, :binary_id, autogenerate: false, source: :Id}
  @foreign_key_type :binary_id

  schema "Guild" do
    field :hostility_id, :binary_id, source: :HostilityId
    field :alliance_guild_id, :binary_id, source: :AllianceGuildId
    field :name, :string, source: :Name
    field :logo, :binary, source: :Logo
    field :score, :integer, source: :Score
    field :notice, :string, source: :Notice

    has_many :members, OpenMuWeb.OpenMU.GuildMember, foreign_key: :guild_id
  end
end
