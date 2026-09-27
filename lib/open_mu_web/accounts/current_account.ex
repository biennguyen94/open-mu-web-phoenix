defmodule OpenMuWeb.Accounts.CurrentAccount do
  @moduledoc """
  The logged-in account as seen by the web layer. `gm?` is computed from the
  database on every request (an account is a Game Master when one of its
  characters has `CharacterStatus = 32`), unlike the Next.js app which froze the
  role in the JWT at login time.
  """
  @enforce_keys [:id, :login_name]
  defstruct [:id, :login_name, :email, gm?: false]

  @type t :: %__MODULE__{
          id: String.t(),
          login_name: String.t(),
          email: String.t() | nil,
          gm?: boolean()
        }

  @doc ~s|NextAuth role name used by `/api/auth/session` ("GAME_MASTER" / "USER").|
  def role(%__MODULE__{gm?: true}), do: "GAME_MASTER"
  def role(%__MODULE__{}), do: "USER"
end
