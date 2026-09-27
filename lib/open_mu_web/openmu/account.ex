defmodule OpenMuWeb.OpenMU.Account do
  @moduledoc """
  `data."Account"` (OpenMU-owned). Only the columns used by the website are mapped.
  `IsTemplate`, `LanguageIsoCode` and `IsBot` are left to their DB defaults.
  """
  use Ecto.Schema

  @schema_prefix "data"
  @primary_key {:id, :binary_id, autogenerate: false, source: :Id}
  @foreign_key_type :binary_id

  schema "Account" do
    field :vault_id, :binary_id, source: :VaultId
    field :login_name, :string, source: :LoginName
    field :password_hash, :string, source: :PasswordHash, redact: true
    field :security_code, :string, source: :SecurityCode, redact: true
    field :email, :string, source: :EMail
    field :registration_date, :utc_datetime_usec, source: :RegistrationDate
    field :state, :integer, source: :State
    field :time_zone, :integer, source: :TimeZone
    field :vault_password, :string, source: :VaultPassword, redact: true
    field :is_vault_extended, :boolean, source: :IsVaultExtended

    has_many :characters, OpenMuWeb.OpenMU.Character, foreign_key: :account_id
  end
end
