defmodule OpenMuWeb.Accounts do
  @moduledoc """
  Accounts (`data."Account"`): login, registration, password change and the
  Game Master check. Ports of `lib/auth.ts`, `app/api/account/register` and
  `app/api/account/changepassword`, with the security fixes of decision D1
  (see `docs/AUTH.md`).

  Passwords are bcrypt hashes shared with the OpenMU game server: existing hashes
  are `$2a$` (OpenMU), new ones `$2b$` with cost 10 (same as the Next.js app).
  """
  import Ecto.Query

  alias OpenMuWeb.Accounts.{CurrentAccount, Registration}
  alias OpenMuWeb.OpenMU.{Account, Character, Ids}
  alias OpenMuWeb.Repo

  @log_rounds 10

  ## Login

  @doc """
  Checks credentials (exact, case-sensitive `LoginName` match, like NextAuth's
  `authorize`). Returns `{:ok, %CurrentAccount{}}` or `{:error, :invalid_credentials}`.
  """
  def authenticate(login_name, password)
      when is_binary(login_name) and is_binary(password) and login_name != "" and password != "" do
    account = Repo.get_by(Account, login_name: login_name)

    cond do
      is_nil(account) ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      verify_password(password, account.password_hash) ->
        {:ok, current_account(account)}

      true ->
        {:error, :invalid_credentials}
    end
  end

  def authenticate(_login_name, _password), do: {:error, :invalid_credentials}

  @doc "Loads the account of a session (`nil` when it no longer exists)."
  def get_current_account(account_id) when is_binary(account_id) do
    case Ecto.UUID.cast(account_id) do
      {:ok, id} -> if account = Repo.get(Account, id), do: current_account(account)
      :error -> nil
    end
  end

  def get_current_account(_), do: nil

  @doc "True when one of the account's characters has `CharacterStatus = 32` (GameMaster)."
  def gm?(account_id) do
    gm = Ids.game_master_status()

    Repo.exists?(
      from c in Character, where: c.account_id == ^account_id and c.character_status == ^gm
    )
  end

  defp current_account(%Account{} = account) do
    %CurrentAccount{
      id: account.id,
      login_name: account.login_name,
      email: account.email,
      gm?: gm?(account.id)
    }
  end

  defp verify_password(password, hash) when is_binary(hash) do
    Bcrypt.verify_pass(password, hash)
  rescue
    # malformed hash in the database
    ArgumentError -> false
  end

  defp verify_password(_password, _hash), do: false

  ## Registration

  @doc """
  Registers an account from the API/form payload (string keys `LoginName`,
  `EMail`, `Password`, `RepeatPassword`).

  Returns `{:ok, %Account{}}`, `{:error, {:validation, issues}}` (zod-format issues),
  `{:error, :email_taken}` or `{:error, :username_taken}` — checked in that order,
  like the Next.js route. Creates the same row as the Next.js app: new UUID,
  bcrypt cost 10, empty security code and vault password, `State 0`, `TimeZone 0`,
  no vault; `IsTemplate` / `LanguageIsoCode` / `IsBot` keep their DB defaults.
  """
  def register(params) do
    with {:ok, attrs} <- validate_registration(params),
         :ok <- ensure_available(attrs) do
      %Account{
        id: Ecto.UUID.generate(),
        login_name: attrs.login_name,
        email: attrs.email,
        password_hash: hash_password(attrs.password),
        security_code: "",
        registration_date: DateTime.utc_now(),
        state: 0,
        time_zone: 0,
        vault_password: "",
        is_vault_extended: false
      }
      |> Repo.insert()
      |> case do
        {:ok, account} -> {:ok, account}
        {:error, _} -> {:error, :insert_failed}
      end
    end
  rescue
    # e.g. unique index violation when two registrations race
    _ in [Postgrex.Error, Ecto.ConstraintError] -> {:error, :insert_failed}
  end

  defp validate_registration(params) do
    case Registration.validate(params) do
      {:ok, attrs} -> {:ok, attrs}
      {:error, issues} -> {:error, {:validation, issues}}
    end
  end

  defp ensure_available(%{login_name: login_name, email: email}) do
    cond do
      Repo.exists?(from a in Account, where: a.email == ^email) ->
        {:error, :email_taken}

      Repo.exists?(from a in Account, where: a.login_name == ^login_name) ->
        {:error, :username_taken}

      true ->
        :ok
    end
  end

  ## Password change

  @doc """
  Changes the password of the **given (logged-in) account**. Security fix R1: the
  Next.js API updated the account named in the request body instead.

  Checks, in the order of the Next.js route: new == old, new == repeat, old
  password correct. There is no server-side length rule for the new password
  (the Next.js form only had `minlength=8`); kept for parity.
  """
  def change_password(%CurrentAccount{id: id}, old_password, new_password, repeat_password) do
    cond do
      old_password == new_password ->
        {:error, :same_password}

      new_password != repeat_password ->
        {:error, :repeat_mismatch}

      not (is_binary(old_password) and is_binary(new_password)) ->
        {:error, :invalid}

      true ->
        account = Repo.get!(Account, id)

        if verify_password(old_password, account.password_hash) do
          {1, _} =
            from(a in Account, where: a.id == ^id)
            |> Repo.update_all(set: [password_hash: hash_password(new_password)])

          :ok
        else
          {:error, :wrong_old_password}
        end
    end
  end

  @doc "User-facing message of a password change result (same texts as the Next.js API)."
  def change_password_message(:ok), do: "Password changes successfully"

  def change_password_message({:error, :same_password}),
    do: "New password and old password are the same!"

  def change_password_message({:error, :repeat_mismatch}),
    do: "New password and Reapeat password should match!"

  def change_password_message({:error, :wrong_old_password}),
    do: "The old password you inserted isn't correct!"

  def change_password_message({:error, _}), do: "There was a problem try again later"

  @doc "Hashes a password like the website always did (bcrypt, cost 10, `$2b$`)."
  def hash_password(password) do
    Bcrypt.hash_pwd_salt(password,
      log_rounds: Application.get_env(:bcrypt_elixir, :log_rounds, @log_rounds)
    )
  end
end
