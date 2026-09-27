defmodule OpenMuWeb.Characters do
  @moduledoc """
  Character panel data and operations (ports of `app/characters/page.tsx` and
  `app/api/characters/{addstats,reset,resetStats,pkclear}`), see
  `docs/FEATURES.md` → Character operations.

  Game rules are the Next.js ones (decision D2): reset needs `Level >= LVL_TO_RESET`
  and `Resets < MAX_RESET`, sets Level 1 / Resets + 1 and moves the character, but
  keeps Experience and LevelUpPoints; reset stats sets every stat to 20 and refunds
  `Σ(value - 20)` points; PK clear sets `State = 0`, `StateRemainingSeconds = 0`.

  Security fixes (decision D1):

    * R3 — the character must belong to the logged-in account (`AccountId`);
    * R2 — stat amounts must be non-negative integers;
    * R4 — the reset location comes from the character's class in the database;
    * R5 — every check runs again inside the transaction with the character and
      its inventory rows locked (`FOR UPDATE`), so concurrent requests cannot
      spend the same zen / points twice.

  Operations return `:ok` or `{:error, reason}` (see `t:error/0`); the web layer
  turns reasons into the per-route messages / status codes of the Next.js API.
  """
  import Ecto.Query

  alias OpenMuWeb.Accounts.CurrentAccount
  alias OpenMuWeb.{Float32, GameServer, Repo, Settings}
  alias OpenMuWeb.OpenMU.{Character, Ids, ItemStorage, StatAttribute}

  @type error ::
          :disabled
          | :not_logged_in
          | :forbidden
          | :online
          | :server_unreachable
          | :invalid
          | :not_enough_points
          | {:not_eligible, integer(), integer()}
          | {:not_enough_zen, integer()}
          | :failed

  @stat_keys ~w(str agi vit ene lead)

  ## Panel data

  # MAX(CASE ... END) without ELSE, like the Next.js characters query.
  defmacrop pivot(sa, definition_id) do
    quote do
      fragment(
        "MAX(CASE WHEN ? = ? THEN ? END)",
        unquote(sa).definition_id,
        type(unquote(definition_id), Ecto.UUID),
        unquote(sa).value
      )
    end
  end

  @doc """
  Characters of the account with resets, level, master level, free points and
  stats (pivot of `StatAttribute`, **no** `ELSE 0`: a missing attribute is nil).
  Same query as the Next.js page, plus `ORDER BY CharacterSlot` (the Next.js query
  had no ORDER BY, so its card order was arbitrary).
  """
  def list_for_account(%CurrentAccount{id: account_id}) do
    ids = [Ids.resets(), Ids.level(), Ids.master_level() | Ids.stat_ids()]

    from(sa in StatAttribute,
      join: c in Character,
      on: sa.character_id == c.id,
      where: c.account_id == ^account_id and sa.definition_id in ^ids,
      group_by: [
        c.name,
        c.character_class_id,
        c.level_up_points,
        c.master_level_up_points,
        c.character_slot
      ],
      order_by: c.character_slot,
      select: %{
        name: c.name,
        character_class_id: c.character_class_id,
        level_up_points: c.level_up_points,
        master_level_up_points: c.master_level_up_points,
        resets: pivot(sa, ^Ids.resets()),
        lvl: pivot(sa, ^Ids.level()),
        masterlvl: pivot(sa, ^Ids.master_level()),
        strength: pivot(sa, ^Ids.strength()),
        agility: pivot(sa, ^Ids.agility()),
        vitality: pivot(sa, ^Ids.vitality()),
        energy: pivot(sa, ^Ids.energy()),
        leadership: pivot(sa, ^Ids.leadership())
      }
    )
    |> Repo.all()
    |> Enum.map(fn row ->
      Map.new(row, fn
        {key, value} when is_float(value) -> {key, Float32.normalize(value)}
        pair -> pair
      end)
    end)
  end

  @doc "Whether the operation is enabled (its zen cost is configured)."
  def enabled?(:reset), do: not is_nil(Settings.zen_to_reset())
  def enabled?(:pk_clear), do: not is_nil(Settings.zen_to_pkclear())
  def enabled?(:reset_stats), do: not is_nil(Settings.zen_to_reset_stats())
  def enabled?(:add_stats), do: true

  ## Add stats

  @doc """
  Adds points to Strength, Agility, Vitality, Energy and Leadership.
  `amounts` has the keys `"str" "agi" "vit" "ene" "lead"`; each must be an integer >= 0.
  Like the Next.js app, Leadership is added only if the character has that
  attribute, while the points are always deducted (B5, kept).
  """
  def add_stats(account, name, amounts) do
    with {:ok, character} <- owned(account, name),
         :ok <- ensure_offline(character.name),
         {:ok, values} <- validate_amounts(amounts) do
      total = Enum.sum(values)

      transaction(fn ->
        character = lock_character!(character.id)
        if character.level_up_points < total, do: Repo.rollback(:not_enough_points)

        for {definition_id, amount} <- Enum.zip(Ids.stat_ids(), values), amount != 0 do
          stat_query(character.id, [definition_id]) |> Repo.update_all(inc: [value: amount])
        end

        update_character!(character.id, inc: [level_up_points: -total])
      end)
    end
  end

  defp validate_amounts(amounts) when is_map(amounts) do
    values = Enum.map(@stat_keys, &non_negative_integer(Map.get(amounts, &1)))
    if Enum.all?(values, &is_integer/1), do: {:ok, values}, else: {:error, :invalid}
  end

  defp validate_amounts(_), do: {:error, :invalid}

  defp non_negative_integer(value) when is_integer(value) and value >= 0, do: value

  defp non_negative_integer(value) when is_float(value) and value >= 0 do
    if value == Float.round(value), do: trunc(value), else: nil
  end

  defp non_negative_integer(_), do: nil

  ## PK clear

  @doc "Clears the PK status for `NEXT_PUBLIC_ZEN_TO_PKCLEAR` zen."
  def pk_clear(account, name) do
    with {:ok, zen} <- zen_cost(Settings.zen_to_pkclear()),
         {:ok, character} <- owned(account, name),
         :ok <- ensure_offline(character.name) do
      transaction(fn ->
        character = lock_character!(character.id)
        pay!(character, zen)
        update_character!(character.id, set: [state: 0, state_remaining_seconds: 0])
      end)
    end
  end

  ## Reset

  @doc """
  Resets the character for `NEXT_PUBLIC_ZEN_TO_RESET` zen when its level is at
  least `LVL_TO_RESET` and its resets are below `MAX_RESET`.
  """
  def reset(account, name) do
    with {:ok, zen} <- zen_cost(Settings.zen_to_reset()),
         {:ok, character} <- owned(account, name),
         :ok <- ensure_offline(character.name),
         {:ok, min_level, max_reset} <- reset_rules() do
      transaction(fn ->
        character = lock_character!(character.id)

        # Same eligibility query as the Next.js route: both rows must match.
        eligible =
          from(sa in StatAttribute,
            where:
              sa.character_id == ^character.id and
                ((sa.definition_id == ^Ids.level() and sa.value >= ^min_level) or
                   (sa.definition_id == ^Ids.resets() and sa.value < ^max_reset))
          )
          |> Repo.aggregate(:count)

        if eligible != 2, do: Repo.rollback({:not_eligible, min_level, max_reset})

        pay!(character, zen)
        stat_query(character.id, [Ids.resets()]) |> Repo.update_all(inc: [value: 1])
        stat_query(character.id, [Ids.level()]) |> Repo.update_all(set: [value: 1.0])

        {map_id, x, y} = Ids.reset_location(character.character_class_id)

        update_character!(character.id,
          set: [current_map_id: map_id, position_x: x, position_y: y]
        )
      end)
    end
  end

  defp reset_rules do
    case {Settings.lvl_to_reset(), Settings.max_reset()} do
      {level, max} when is_integer(level) and is_integer(max) -> {:ok, level, max}
      _ -> {:error, :failed}
    end
  end

  ## Reset stats

  @doc """
  Sets Strength/Agility/Vitality/Energy/Leadership to 20 and refunds `Σ(value - 20)`
  free points for `NEXT_PUBLIC_ZEN_TO_RESET_STATS` zen (fixed base 20 — discrepancy
  B3 with OpenMU's per-class base values, kept by decision D2).
  """
  def reset_stats(account, name) do
    with {:ok, zen} <- zen_cost(Settings.zen_to_reset_stats()),
         {:ok, character} <- owned(account, name),
         :ok <- ensure_offline(character.name) do
      transaction(fn ->
        character = lock_character!(character.id)

        refund =
          stat_query(character.id, Ids.stat_ids())
          |> select([sa], sa.value)
          |> Repo.all()
          |> Enum.map(&(&1 - 20))
          |> Enum.sum()
          |> Float32.normalize()

        unless is_integer(refund), do: Repo.rollback(:failed)

        pay!(character, zen)
        stat_query(character.id, Ids.stat_ids()) |> Repo.update_all(set: [value: 20.0])
        update_character!(character.id, inc: [level_up_points: refund])
      end)
    end
  end

  ## Helpers

  defp owned(nil, _name), do: {:error, :not_logged_in}

  defp owned(%CurrentAccount{id: account_id}, name) when is_binary(name) do
    case Repo.one(from c in Character, where: c.name == ^name and c.account_id == ^account_id) do
      nil -> {:error, :forbidden}
      character -> {:ok, character}
    end
  end

  defp owned(%CurrentAccount{}, _name), do: {:error, :forbidden}

  @doc """
  The Next.js routes refused to change a character while it is connected
  (`playersList` of the game server status) and when the status is unavailable.
  """
  def ensure_offline(name) do
    case GameServer.status() do
      {:ok, status} ->
        if name in GameServer.players_list(status), do: {:error, :online}, else: :ok

      {:error, _} ->
        {:error, :server_unreachable}
    end
  end

  defp zen_cost(nil), do: {:error, :disabled}
  defp zen_cost(zen), do: {:ok, zen}

  defp lock_character!(id) do
    from(c in Character, where: c.id == ^id, lock: "FOR UPDATE") |> Repo.one!()
  end

  # Zen is the Money of the character's inventory; checked with the row locked.
  defp pay!(%Character{inventory_id: inventory_id}, zen) do
    storage =
      inventory_id &&
        from(s in ItemStorage, where: s.id == ^inventory_id, lock: "FOR UPDATE") |> Repo.one()

    if is_nil(storage) or storage.money < zen, do: Repo.rollback({:not_enough_zen, zen})

    from(s in ItemStorage, where: s.id == ^storage.id) |> Repo.update_all(inc: [money: -zen])
  end

  defp stat_query(character_id, definition_ids) do
    from sa in StatAttribute,
      where: sa.character_id == ^character_id and sa.definition_id in ^definition_ids
  end

  defp update_character!(id, changes) do
    {1, _} = from(c in Character, where: c.id == ^id) |> Repo.update_all(changes)
  end

  defp transaction(fun) do
    case Repo.transaction(fun) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  rescue
    e in [Postgrex.Error, DBConnection.ConnectionError, Ecto.QueryError] ->
      require Logger
      Logger.error("character operation failed: " <> Exception.message(e))
      {:error, :failed}
  end
end
