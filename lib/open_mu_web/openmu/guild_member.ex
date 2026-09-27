defmodule OpenMuWeb.OpenMU.GuildMember do
  @moduledoc """
  `guild."GuildMember"` (OpenMU-owned). The primary key is the character id.
  `Status` is OpenMU `GuildPosition` (0 Undefined, 1 NormalMember, 2 GuildMaster,
  3 BattleMaster, 4 AssistantMaster).
  """
  use Ecto.Schema

  @schema_prefix "guild"
  @primary_key {:id, :binary_id, autogenerate: false, source: :Id}
  @foreign_key_type :binary_id

  schema "GuildMember" do
    field :status, :integer, source: :Status

    belongs_to :guild, OpenMuWeb.OpenMU.Guild, source: :GuildId
    belongs_to :character, OpenMuWeb.OpenMU.Character, define_field: false, foreign_key: :id
  end
end
