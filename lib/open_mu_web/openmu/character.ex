defmodule OpenMuWeb.OpenMU.Character do
  @moduledoc """
  `data."Character"` (OpenMU-owned). Level / resets / stats live in
  `data."StatAttribute"`, not here. Only website-relevant columns are mapped.
  """
  use Ecto.Schema

  @schema_prefix "data"
  @primary_key {:id, :binary_id, autogenerate: false, source: :Id}
  @foreign_key_type :binary_id

  schema "Character" do
    field :character_class_id, :binary_id, source: :CharacterClassId
    field :current_map_id, :binary_id, source: :CurrentMapId
    field :name, :string, source: :Name
    field :experience, :integer, source: :Experience
    field :level_up_points, :integer, source: :LevelUpPoints
    field :master_level_up_points, :integer, source: :MasterLevelUpPoints
    field :position_x, :integer, source: :PositionX
    field :position_y, :integer, source: :PositionY
    field :player_kill_count, :integer, source: :PlayerKillCount
    field :state_remaining_seconds, :integer, source: :StateRemainingSeconds
    field :state, :integer, source: :State
    field :character_status, :integer, source: :CharacterStatus

    belongs_to :account, OpenMuWeb.OpenMU.Account, source: :AccountId
    belongs_to :inventory, OpenMuWeb.OpenMU.ItemStorage, source: :InventoryId
    has_many :stat_attributes, OpenMuWeb.OpenMU.StatAttribute, foreign_key: :character_id
    has_one :guild_member, OpenMuWeb.OpenMU.GuildMember, foreign_key: :id
  end
end
