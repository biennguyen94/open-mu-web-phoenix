defmodule OpenMuWeb.RankingsTest do
  use OpenMuWeb.DataCase, async: true

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.OpenMU.Ids
  alias OpenMuWeb.Rankings

  describe "top_characters/1" do
    setup do
      # resets desc, then level desc, then master level desc
      set_stat!("test1Dk", Ids.resets(), 50.0)
      set_stat!("test1Dk", Ids.level(), 10.0)
      set_stat!("test1Dw", Ids.resets(), 50.0)
      set_stat!("test1Dw", Ids.level(), 20.0)
      set_stat!("test400Dk", Ids.resets(), 45.0)
      set_stat!("test400Dk", Ids.level(), 300.0)
      set_stat!("test400Dk", Ids.master_level(), 5.0)
      set_stat!("test400Dw", Ids.resets(), 45.0)
      set_stat!("test400Dw", Ids.level(), 300.0)
      set_stat!("test400Dw", Ids.master_level(), 7.0)
      :ok
    end

    test "orders by resets, level, master level" do
      assert ["test1Dw", "test1Dk", "test400Dw", "test400Dk"] ==
               Rankings.top_characters(4) |> Enum.map(& &1.name)
    end

    test "returns normalized values; a missing Master Level row counts as 0 (ELSE 0)" do
      [first | _] = Rankings.top_characters(1)
      assert %{name: "test1Dw", resets: 50, lvl: 20, masterlvl: 0} = first
      assert first.character_class_id == character!("test1Dw").character_class_id
      assert first.character_id == character!("test1Dw").id
    end

    test "respects the limit and includes GM characters" do
      assert length(Rankings.top_characters(10)) == 10
      names = Rankings.top_characters(100) |> Enum.map(& &1.name)
      assert "testgmDk" in names
    end
  end

  test "top_killers/1 orders by PlayerKillCount" do
    update_character!("test2Dk", player_kill_count: 1000)
    update_character!("test3Dk", player_kill_count: 999)

    assert [
             %{name: "test2Dk", player_kill_count: 1000},
             %{name: "test3Dk", player_kill_count: 999}
           ] =
             Rankings.top_killers(2)

    assert length(Rankings.top_killers()) == 30
  end

  test "online_players/1 returns characters whose name is in the list" do
    rows = Rankings.online_players(["test1Dk", "nobody"])
    assert [%{name: "test1Dk", position_x: x, position_y: y, current_map_id: map}] = rows
    assert is_integer(x) and is_integer(y) and is_binary(map)
    assert Rankings.online_players([]) == []
  end
end
