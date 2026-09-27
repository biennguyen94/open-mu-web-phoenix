defmodule OpenMuWebWeb.Api.CharacterController do
  @moduledoc """
  Character operations (ports of `app/api/characters/*`, all `POST`, logged-in
  account via the session cookie):

    * `/api/characters/addstats`   `{"name","str","agi","vit","ene","lead"}`
    * `/api/characters/pkclear`    `{"name"}`
    * `/api/characters/reset`      `{"name","clasId"}` (`clasId` ignored — R4)
    * `/api/characters/resetStats` `{"name","clasId"}` (`clasId` unused, as before)

  Same messages / status codes as the Next.js routes (`OpenMuWebWeb.CharacterMessages`);
  security fixes R2–R5 described in `OpenMuWeb.Characters`.
  """
  use OpenMuWebWeb, :controller

  import OpenMuWebWeb.Api.ApiJSON

  alias OpenMuWeb.Characters
  alias OpenMuWebWeb.CharacterMessages

  def add_stats(conn, params),
    do: run(conn, :add_stats, &Characters.add_stats(&1, params["name"], params))

  def pk_clear(conn, params), do: run(conn, :pk_clear, &Characters.pk_clear(&1, params["name"]))
  def reset(conn, params), do: run(conn, :reset, &Characters.reset(&1, params["name"]))

  def reset_stats(conn, params),
    do: run(conn, :reset_stats, &Characters.reset_stats(&1, params["name"]))

  defp run(conn, op, fun) do
    result =
      cond do
        # The Next.js routes checked "Function disabled" before reading the body.
        not Characters.enabled?(op) -> {:error, :disabled}
        conn.private[:body_parse_error] -> {:error, :failed}
        true -> fun.(conn.assigns[:current_account])
      end

    {status, message} = CharacterMessages.response(op, result)
    send_message(conn, status, message)
  end
end
