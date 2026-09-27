defmodule OpenMuWeb.GuildsTest do
  use OpenMuWeb.DataCase, async: true

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.Guilds

  setup do
    insert_guild!("Alpha", 120, logo: <<1, 2, 255>>, members: [{"testgmDk", 2}, {"test1Dk", 1}])
    insert_guild!("Beta", 80, members: [{"test400Dw", 2}])
    insert_guild!("Empty", 10)
    :ok
  end

  test "top/1 orders by score" do
    assert ["Alpha", "Beta", "Empty"] == Guilds.top(30) |> Enum.map(& &1.name)
    assert [%{name: "Alpha", logo: <<1, 2, 255>>, score: 120}] = Guilds.top(1)
  end

  test "members/1 returns names and statuses; unknown or empty guilds give []" do
    assert Enum.sort_by(Guilds.members("Alpha"), & &1.name) == [
             %{name: "test1Dk", status: 1},
             %{name: "testgmDk", status: 2}
           ]

    assert Guilds.members("Empty") == []
    assert Guilds.members("Nope") == []
  end

  test "position_label/1 only labels the Guild Master (like the Next.js popup)" do
    assert Guilds.position_label(2) == "Guild Master"
    assert Guilds.position_label(1) == ""
    assert Guilds.position_label(3) == ""
  end
end
