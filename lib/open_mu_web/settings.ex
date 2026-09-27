defmodule OpenMuWeb.Settings do
  @moduledoc """
  Website settings read at runtime (`config :open_mu_web, :settings`, filled in
  `config/runtime.exs` from the same environment variables as the Next.js app).

  Semantics follow the Next.js app: an empty or missing zen cost disables the
  corresponding feature (reset, PK clear, reset stats), and an empty download link
  hides that download button.
  """

  @doc "Base URL of the OpenMU admin panel (`/api/status` is appended), or nil."
  def game_server_url, do: string(:game_server_url)

  def google_drive_link, do: string(:google_drive_link)
  def mediafire_link, do: string(:mediafire_link)
  def mega_link, do: string(:mega_link)
  def discord_link, do: string(:discord_link)

  @doc "Zen needed to reset, or nil when reset is disabled."
  def zen_to_reset, do: integer(:zen_to_reset)

  @doc "Minimum level to reset (compared with `>=`), or nil if not configured."
  def lvl_to_reset, do: integer(:lvl_to_reset)

  @doc "Resets must be strictly lower than this value, or nil if not configured."
  def max_reset, do: integer(:max_reset)

  @doc "Zen needed to clear PK, or nil when PK clear is disabled."
  def zen_to_pkclear, do: integer(:zen_to_pkclear)

  @doc "Zen needed to reset stats, or nil when reset stats is disabled."
  def zen_to_reset_stats, do: integer(:zen_to_reset_stats)

  @doc false
  def parse_integer(nil), do: nil

  def parse_integer(value) when is_binary(value) do
    case Integer.parse(String.trim(value)) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp string(key) do
    case fetch(key) do
      value when is_binary(value) ->
        if String.trim(value) == "", do: nil, else: value

      _ ->
        nil
    end
  end

  defp integer(key), do: key |> string() |> parse_integer()

  defp fetch(key) do
    :open_mu_web
    |> Application.get_env(:settings, [])
    |> Keyword.get(key)
  end
end
