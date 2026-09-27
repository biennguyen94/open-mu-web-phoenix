defmodule OpenMuWeb.OpenMU.Ids do
  @moduledoc """
  Hard-coded OpenMU identifiers used by the website (VERIFIED against the DB and
  the OpenMU source on 2026-09-27, see `docs/DATABASE.md` §3).
  """

  # config."AttributeDefinition" ids (StatAttribute.DefinitionId)
  @resets "89a891a7-f9f9-4ab5-af36-12056e53a5f7"
  @level "560931ad-0901-4342-b7f4-fd2e2fcc0563"
  @master_level "70cd8c10-391a-4c51-9aa4-a854600e3a9f"
  @strength "123282fe-fead-448e-ad2c-baece939b4b1"
  @agility "1ae9c014-e3cd-4703-bd05-1b65f5f94ceb"
  @vitality "6ca5c3a6-b109-45a5-87a7-fdcb107b4982"
  @energy "01b0ef28-f7a0-46b5-97ba-2b624a54cd75"
  @leadership "6af2c9df-3ae4-4721-8462-9a8ec7f56fe4"

  def resets, do: @resets
  def level, do: @level
  def master_level, do: @master_level
  def strength, do: @strength
  def agility, do: @agility
  def vitality, do: @vitality
  def energy, do: @energy
  def leadership, do: @leadership

  @doc "The attributes a player distributes points to (Str, Agi, Vit, Ene, Leadership)."
  def stat_ids, do: [@strength, @agility, @vitality, @energy, @leadership]

  @doc "Classes that show / use Leadership in the Add Stats card (Dark Lord, Lord Emperor)."
  def leadership_class?(class_id),
    do:
      class_id in ["00000040-0010-0000-0000-000000000000", "00000040-0011-0000-0000-000000000000"]

  @lorencia {"00000300-0000-0000-0000-000000000000", 141, 121}
  @noria {"00000300-0003-0000-0000-000000000000", 176, 116}
  @elbeland {"00000300-0033-0000-0000-000000000000", 51, 226}
  @elf_classes ~w(00000040-000b-0000-0000-000000000000 00000040-000a-0000-0000-000000000000 00000040-0008-0000-0000-000000000000)
  @summoner_classes ~w(00000040-0017-0000-0000-000000000000 00000040-0016-0000-0000-000000000000 00000040-0014-0000-0000-000000000000)

  @doc """
  `{map_id, x, y}` a character is moved to by a reset (port of the reset route):
  elves → Noria (176, 116), summoners → Elbeland (51, 226), others → Lorencia (141, 121).
  """
  def reset_location(class_id) when class_id in @elf_classes, do: @noria
  def reset_location(class_id) when class_id in @summoner_classes, do: @elbeland
  def reset_location(_class_id), do: @lorencia

  @doc "OpenMU `CharacterStatus.GameMaster`."
  def game_master_status, do: 32

  @doc "OpenMU `GuildPosition.GuildMaster`."
  def guild_master_position, do: 2

  # config."CharacterClass" id => avatar (port of app/_utils/characterAvatarReturn.ts)
  @class_avatars %{
    "00000040-0000-0000-0000-000000000000" => "dw",
    "00000040-0002-0000-0000-000000000000" => "dw",
    "00000040-0003-0000-0000-000000000000" => "dw",
    "00000040-0004-0000-0000-000000000000" => "dk",
    "00000040-0006-0000-0000-000000000000" => "dk",
    "00000040-0007-0000-0000-000000000000" => "dk",
    "00000040-0008-0000-0000-000000000000" => "elf",
    "00000040-000a-0000-0000-000000000000" => "elf",
    "00000040-000b-0000-0000-000000000000" => "elf",
    "00000040-000c-0000-0000-000000000000" => "mg",
    "00000040-000d-0000-0000-000000000000" => "mg",
    "00000040-0010-0000-0000-000000000000" => "dl",
    "00000040-0011-0000-0000-000000000000" => "dl",
    "00000040-0014-0000-0000-000000000000" => "sum",
    "00000040-0016-0000-0000-000000000000" => "sum",
    "00000040-0017-0000-0000-000000000000" => "sum",
    "00000040-0018-0000-0000-000000000000" => "rf",
    "00000040-0019-0000-0000-000000000000" => "rf"
  }

  @doc "Avatar image path for a character class id, or nil for an unknown class."
  def class_avatar(class_id) do
    case Map.get(@class_avatars, class_id) do
      nil -> nil
      name -> "/images/avatars/#{name}.jpg"
    end
  end

  # config."GameMapDefinition" id => display name (port of app/_utils/mapEnum.ts,
  # names kept as in the Next.js app for UI parity).
  @map_names %{
    "00000300-0019-0000-0000-000000000000" => "Kalima2",
    "00000300-0045-0000-0000-000000000000" => "FortressOfImperialGuardian1",
    "00000300-0021-0000-0000-000000000000" => "Aida",
    "00000300-0022-0000-0000-000000000000" => "CrywolfFortress",
    "00000300-0024-0000-0000-000000000000" => "Kalima7",
    "00000300-0025-0000-0000-000000000000" => "KanturuI",
    "00000300-0026-0000-0000-000000000000" => "KanturuIII",
    "00000300-0027-0000-0000-000000000000" => "KanturuEvent",
    "00000300-002d-0000-0000-000000000000" => "IllusionTemple1",
    "00000300-002e-0000-0000-000000000000" => "IllusionTemple2",
    "00000300-002f-0000-0000-000000000000" => "IllusionTemple3",
    "00000300-0030-0000-0000-000000000000" => "IllusionTemple4",
    "00000300-0031-0000-0000-000000000000" => "IllusionTemple5",
    "00000300-0032-0000-0000-000000000000" => "IllusionTemple6",
    "00000300-0033-0000-0000-000000000000" => "Elvenland",
    "00000300-0000-0000-0000-000000000000" => "Lorencia",
    "00000300-0001-0000-0000-000000000000" => "Dungeon",
    "00000300-0002-0000-0000-000000000000" => "Devias",
    "00000300-0003-0000-0000-000000000000" => "Noria",
    "00000300-0004-0000-0000-000000000000" => "LostTower",
    "00000300-0005-0000-0000-000000000000" => "Exile",
    "00000300-0006-0000-0000-000000000000" => "Arena",
    "00000300-0007-0000-0000-000000000000" => "Atlans",
    "00000300-0008-0000-0000-000000000000" => "Tarkan",
    "00000300-0009-0001-0000-000000000000" => "DevilSquare1",
    "00000300-0047-0000-0000-000000000000" => "FortressOfImperialGuardian3",
    "00000300-0048-0000-0000-000000000000" => "FortressOfImperialGuardian4",
    "00000300-0050-0000-0000-000000000000" => "Karutan1",
    "00000300-0051-0000-0000-000000000000" => "Karutan2",
    "00000300-0009-0002-0000-000000000000" => "DevilSquare2",
    "00000300-0009-0003-0000-000000000000" => "DevilSquare3",
    "00000300-0009-0004-0000-000000000000" => "DevilSquare4",
    "00000300-000a-0000-0000-000000000000" => "Icarus",
    "00000300-000b-0000-0000-000000000000" => "BloodCastle1",
    "00000300-000c-0000-0000-000000000000" => "BloodCastle2",
    "00000300-000d-0000-0000-000000000000" => "BloodCastle3",
    "00000300-000e-0000-0000-000000000000" => "BloodCastle4",
    "00000300-000f-0000-0000-000000000000" => "BloodCastle5",
    "00000300-0010-0000-0000-000000000000" => "BloodCastle6",
    "00000300-0011-0000-0000-000000000000" => "BloodCastle7",
    "00000300-0012-0000-0000-000000000000" => "ChaosCastle1",
    "00000300-0013-0000-0000-000000000000" => "ChaosCastle2",
    "00000300-0014-0000-0000-000000000000" => "ChaosCastle3",
    "00000300-0015-0000-0000-000000000000" => "ChaosCastle4",
    "00000300-0016-0000-0000-000000000000" => "ChaosCastle5",
    "00000300-0017-0000-0000-000000000000" => "ChaosCastle6",
    "00000300-0018-0000-0000-000000000000" => "Kalima1",
    "00000300-001a-0000-0000-000000000000" => "Kalima3",
    "00000300-001b-0000-0000-000000000000" => "Kalima4",
    "00000300-001c-0000-0000-000000000000" => "Kalima5",
    "00000300-001d-0000-0000-000000000000" => "Kalima6",
    "00000300-001e-0000-0000-000000000000" => "ValleyOfLoren",
    "00000300-001f-0000-0000-000000000000" => "LandOfTrials",
    "00000300-0034-0000-0000-000000000000" => "BloodCastle8",
    "00000300-0020-0005-0000-000000000000" => "DevilSquare5",
    "00000300-0020-0006-0000-000000000000" => "DevilSquare6",
    "00000300-0020-0007-0000-000000000000" => "DevilSquare7",
    "00000300-0028-0000-0000-000000000000" => "SilentMap",
    "00000300-0029-0000-0000-000000000000" => "BarracksOfBalgass",
    "00000300-002a-0000-0000-000000000000" => "BalgassRefuge",
    "00000300-0035-0000-0000-000000000000" => "ChaosCastle7",
    "00000300-0038-0000-0000-000000000000" => "SwampOfCalmness",
    "00000300-0039-0000-0000-000000000000" => "LaCleon",
    "00000300-003a-0000-0000-000000000000" => "LaCleonBoss",
    "00000300-003e-0000-0000-000000000000" => "SantaVillage",
    "00000300-003f-0000-0000-000000000000" => "Vulcanus",
    "00000300-0040-0000-0000-000000000000" => "DuelArena",
    "00000300-0041-0000-0000-000000000000" => "Doppelgaenger1",
    "00000300-0042-0000-0000-000000000000" => "Doppelgaenger2",
    "00000300-0043-0000-0000-000000000000" => "Doppelgaenger3",
    "00000300-0044-0000-0000-000000000000" => "Doppelgaenger4",
    "00000300-0046-0000-0000-000000000000" => "FortressGuardian2",
    "00000300-004f-0000-0000-000000000000" => "LorenMarket"
  }

  @doc "Display name of a map id, or nil (rendered empty, like the Next.js app)."
  def map_name(nil), do: nil
  def map_name(map_id), do: Map.get(@map_names, map_id)
end
