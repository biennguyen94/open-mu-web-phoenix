defmodule OpenMuWeb.OpenMU.StatAttribute do
  @moduledoc """
  `data."StatAttribute"` (OpenMU-owned): one row per (character, attribute
  definition). `Value` is `real` (float4). Definition ids: `OpenMuWeb.OpenMU.Ids`.
  """
  use Ecto.Schema

  @schema_prefix "data"
  @primary_key {:id, :binary_id, autogenerate: false, source: :Id}
  @foreign_key_type :binary_id

  schema "StatAttribute" do
    field :definition_id, :binary_id, source: :DefinitionId
    field :value, :float, source: :Value
    field :account_id, :binary_id, source: :AccountId

    belongs_to :character, OpenMuWeb.OpenMU.Character, source: :CharacterId
  end
end
