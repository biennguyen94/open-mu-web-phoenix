defmodule OpenMuWeb.CharactersTest do
  # One test changes the application settings: run the module serially.
  use OpenMuWeb.DataCase, async: false

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.{Accounts, Characters}
  alias OpenMuWeb.OpenMU.Ids

  @zeros %{"str" => 0, "agi" => 0, "vit" => 0, "ene" => 0, "lead" => 0}

  setup do
    stub_game_server_online(["test1Dl"])
    {:ok, test1} = Accounts.authenticate("test1", "test1")
    {:ok, test400} = Accounts.authenticate("test400", "test400")
    %{test1: test1, test400: test400}
  end

  describe "list_for_account/1" do
    test "pivot without ELSE 0, ordered by slot", %{test1: test1, test400: test400} do
      rows = Characters.list_for_account(test1)
      assert Enum.map(rows, & &1.name) |> Enum.sort() == ~w(test1Dk test1Dl test1Dw test1Elf)
      dk = Enum.find(rows, &(&1.name == "test1Dk"))

      assert %{
               resets: 0,
               lvl: 11,
               strength: 28,
               agility: 20,
               vitality: 25,
               energy: 10,
               level_up_points: 50
             } = dk

      # no Master Level / Leadership rows for this character -> nil (rendered empty)
      assert dk.masterlvl == nil and dk.leadership == nil

      assert is_number(
               Enum.find(Characters.list_for_account(test400), &(&1.name == "test400Dl")).leadership
             )

      slots = Enum.map(rows, &character!(&1.name).character_slot)
      assert slots == Enum.sort(slots)
    end
  end

  describe "add_stats/3" do
    test "adds points and deducts free points", %{test1: test1} do
      assert :ok = Characters.add_stats(test1, "test1Dk", %{@zeros | "str" => 5, "ene" => 2})
      assert stat("test1Dk", Ids.strength()) == 33.0
      assert stat("test1Dk", Ids.energy()) == 12.0
      assert character!("test1Dk").level_up_points == 43
    end

    test "not enough points / invalid amounts (R2)", %{test1: test1} do
      assert Characters.add_stats(test1, "test1Dk", %{@zeros | "str" => 51}) ==
               {:error, :not_enough_points}

      for bad <- [-3, 1.5, "1", nil] do
        assert Characters.add_stats(test1, "test1Dk", %{@zeros | "str" => bad}) ==
                 {:error, :invalid}
      end

      assert Characters.add_stats(test1, "test1Dk", Map.delete(@zeros, "lead")) ==
               {:error, :invalid}

      assert character!("test1Dk").level_up_points == 50
    end

    test "leadership without a Leadership row still costs points (B5, kept)", %{test1: test1} do
      assert :ok = Characters.add_stats(test1, "test1Dk", %{@zeros | "lead" => 3})
      assert character!("test1Dk").level_up_points == 47
      assert stat("test1Dk", Ids.leadership()) == nil
    end

    test "ownership (R3), login and online checks", %{test1: test1} do
      assert Characters.add_stats(test1, "test400Dk", @zeros) == {:error, :forbidden}
      assert Characters.add_stats(nil, "test1Dk", @zeros) == {:error, :not_logged_in}
      assert Characters.add_stats(test1, "test1Dl", @zeros) == {:error, :online}
      stub_game_server_down()
      assert Characters.add_stats(test1, "test1Dk", @zeros) == {:error, :server_unreachable}
    end
  end

  describe "pk_clear/2" do
    test "clears the PK state for zen", %{test1: test1} do
      update_character!("test1Elf", state: 5, state_remaining_seconds: 3600)
      assert :ok = Characters.pk_clear(test1, "test1Elf")

      char = character!("test1Elf")
      assert {char.state, char.state_remaining_seconds} == {0, 0}
      assert money!("test1Elf") == 9_000_000
    end

    test "not enough zen is checked with the row locked (R5)", %{test1: test1} do
      set_money!("test1Elf", 999_999)
      assert Characters.pk_clear(test1, "test1Elf") == {:error, {:not_enough_zen, 1_000_000}}
      assert money!("test1Elf") == 999_999
    end

    test "disabled when the zen setting is empty", %{test1: test1} do
      original = Application.get_env(:open_mu_web, :settings)
      Application.put_env(:open_mu_web, :settings, Keyword.put(original, :zen_to_pkclear, ""))
      on_exit(fn -> Application.put_env(:open_mu_web, :settings, original) end)

      assert Characters.pk_clear(test1, "test1Elf") == {:error, :disabled}
      refute Characters.enabled?(:pk_clear)
    end
  end

  describe "reset/2" do
    test "resets level, adds a reset, charges zen and moves by class from the DB", %{
      test400: test400
    } do
      update_character!("test400Elf", experience: 123_456)
      assert :ok = Characters.reset(test400, "test400Elf")

      char = character!("test400Elf")
      assert stat("test400Elf", Ids.level()) == 1.0
      assert stat("test400Elf", Ids.resets()) == 1.0
      # Noria for elves; Experience and LevelUpPoints unchanged (D2)
      assert {char.current_map_id, char.position_x, char.position_y} ==
               {"00000300-0003-0000-0000-000000000000", 176, 116}

      assert char.experience == 123_456
      assert char.level_up_points == 275
      assert money!("test400Elf") == 9_000_000
    end

    test "other classes go to Lorencia (R4: class from the DB, not the request)", %{
      test400: test400
    } do
      assert :ok = Characters.reset(test400, "test400Dl")

      assert {"00000300-0000-0000-0000-000000000000", 141, 121} ==
               (fn c -> {c.current_map_id, c.position_x, c.position_y} end).(
                 character!("test400Dl")
               )
    end

    test "eligibility: level and max resets", %{test1: test1, test400: test400} do
      assert Characters.reset(test1, "test1Dk") == {:error, {:not_eligible, 400, 6}}
      set_stat!("test400Dk", Ids.resets(), 6.0)
      assert Characters.reset(test400, "test400Dk") == {:error, {:not_eligible, 400, 6}}
    end

    test "zen", %{test400: test400} do
      set_money!("test400Dk", 10)
      assert Characters.reset(test400, "test400Dk") == {:error, {:not_enough_zen, 1_000_000}}
      assert stat("test400Dk", Ids.level()) == 400.0
    end
  end

  describe "reset_stats/2" do
    test "sets stats to 20 and refunds Σ(value - 20) (base 20, D2/B3)", %{test1: test1} do
      # Dark Wizard 18/18/15/30 -> refund (-2 -2 -5 +10) = 1
      assert :ok = Characters.reset_stats(test1, "test1Dw")

      for id <- [Ids.strength(), Ids.agility(), Ids.vitality(), Ids.energy()],
          do: assert(stat("test1Dw", id) == 20.0)

      assert character!("test1Dw").level_up_points == 51
      assert money!("test1Dw") == 9_000_000
    end

    test "includes Leadership for Dark Lords", %{test400: test400} do
      before = character!("test400Dl").level_up_points
      values = for id <- Ids.stat_ids(), do: stat("test400Dl", id)
      assert :ok = Characters.reset_stats(test400, "test400Dl")
      assert stat("test400Dl", Ids.leadership()) == 20.0

      assert character!("test400Dl").level_up_points ==
               before + trunc(Enum.sum(Enum.map(values, &(&1 - 20))))
    end

    test "not enough zen changes nothing", %{test1: test1} do
      set_money!("test1Dw", 0)
      assert Characters.reset_stats(test1, "test1Dw") == {:error, {:not_enough_zen, 1_000_000}}
      assert stat("test1Dw", Ids.energy()) == 30.0
    end
  end
end
