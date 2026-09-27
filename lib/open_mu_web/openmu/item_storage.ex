defmodule OpenMuWeb.OpenMU.ItemStorage do
  @moduledoc """
  `data."ItemStorage"` (OpenMU-owned). `Money` of a character's inventory
  (`Character.InventoryId`) is the zen used by character operations.
  """
  use Ecto.Schema

  @schema_prefix "data"
  @primary_key {:id, :binary_id, autogenerate: false, source: :Id}

  schema "ItemStorage" do
    field :money, :integer, source: :Money
  end
end
