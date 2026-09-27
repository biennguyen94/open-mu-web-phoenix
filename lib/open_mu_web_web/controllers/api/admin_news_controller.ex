defmodule OpenMuWebWeb.Api.AdminNewsController do
  @moduledoc """
  Admin news endpoints (ports of `app/api/admin/news` and `app/api/admin/news/[id]`):

    * `POST /api/admin/news`       `{"title","body"}` → 200 "News added successfully"
    * `DELETE /api/admin/news/:id` → 200 "News deleted successfully"

  Not logged in / not a Game Master → **500** "You can't do this!" (original status);
  invalid body, unknown or malformed id → 400 "There was a problem try again later".
  R3 fixed: the logged-in account must own a GM character.
  """
  use OpenMuWebWeb, :controller

  import OpenMuWebWeb.Api.ApiJSON

  alias OpenMuWeb.News

  @error "There was a problem try again later"

  # The Next.js route read the body (req.json) before checking the session.
  def create(%Plug.Conn{private: %{body_parse_error: true}} = conn, _params),
    do: send_message(conn, 400, @error)

  def create(conn, params) do
    case News.create_article(conn.assigns[:current_account], params["title"], params["body"]) do
      {:ok, _article} -> send_message(conn, 200, "News added successfully")
      {:error, reason} -> error(conn, reason)
    end
  end

  def delete(conn, %{"id" => id}) do
    case News.delete_article(conn.assigns[:current_account], id) do
      :ok -> send_message(conn, 200, "News deleted successfully")
      {:error, reason} -> error(conn, reason)
    end
  end

  defp error(conn, reason) when reason in [:not_logged_in, :forbidden],
    do: send_message(conn, 500, "You can't do this!")

  defp error(conn, _reason), do: send_message(conn, 400, @error)
end
