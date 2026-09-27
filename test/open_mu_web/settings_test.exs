defmodule OpenMuWeb.SettingsTest do
  # Mutates application env, so it must not run concurrently with other tests.
  use ExUnit.Case, async: false

  alias OpenMuWeb.Settings

  setup do
    original = Application.get_env(:open_mu_web, :settings)
    on_exit(fn -> Application.put_env(:open_mu_web, :settings, original) end)
  end

  defp put_settings(settings), do: Application.put_env(:open_mu_web, :settings, settings)

  test "zen costs and reset rules are parsed as integers" do
    put_settings(
      zen_to_reset: "1000000",
      lvl_to_reset: "400",
      max_reset: " 6 ",
      zen_to_pkclear: "1000000",
      zen_to_reset_stats: "500"
    )

    assert Settings.zen_to_reset() == 1_000_000
    assert Settings.lvl_to_reset() == 400
    assert Settings.max_reset() == 6
    assert Settings.zen_to_pkclear() == 1_000_000
    assert Settings.zen_to_reset_stats() == 500
  end

  test "empty or missing zen costs disable the feature (nil), like the Next.js app" do
    put_settings(zen_to_reset: "", zen_to_pkclear: "   ")

    assert Settings.zen_to_reset() == nil
    assert Settings.zen_to_pkclear() == nil
    assert Settings.zen_to_reset_stats() == nil
  end

  test "non-numeric values are treated as not configured" do
    put_settings(zen_to_reset: "abc", lvl_to_reset: "40x")

    assert Settings.zen_to_reset() == nil
    assert Settings.lvl_to_reset() == nil
  end

  test "empty links are hidden (nil)" do
    put_settings(
      mega_link: "",
      discord_link: "https://discord.com/invite/x",
      game_server_url: "http://localhost"
    )

    assert Settings.mega_link() == nil
    assert Settings.mediafire_link() == nil
    assert Settings.discord_link() == "https://discord.com/invite/x"
    assert Settings.game_server_url() == "http://localhost"
  end
end
