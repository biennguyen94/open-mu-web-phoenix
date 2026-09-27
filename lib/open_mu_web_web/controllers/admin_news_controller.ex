defmodule OpenMuWebWeb.AdminNewsController do
  @moduledoc """
  `DELETE /admin/news/:id` — the "Delete" button of the news cards (Game Masters
  only, `require_gm`). Same toasts as `NewsCard.tsx`; the browser returns to the
  page it came from (the Next.js card called `router.refresh()`).
  """
  use OpenMuWebWeb, :controller

  alias OpenMuWeb.News
  alias OpenMuWebWeb.UserAuth

  def delete(conn, %{"id" => id}) do
    conn =
      case News.delete_article(conn.assigns.current_account, id) do
        :ok -> put_flash(conn, :info, "News deleted successfully")
        {:error, _} -> put_flash(conn, :error, "There was a problem try again later")
      end

    redirect(conn, to: UserAuth.return_path(conn))
  end
end
