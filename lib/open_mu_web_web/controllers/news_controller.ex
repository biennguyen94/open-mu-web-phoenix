defmodule OpenMuWebWeb.NewsController do
  @moduledoc "Home page news list and news detail (`app/page.tsx`, `app/news/[id]/page.tsx`)."
  use OpenMuWebWeb, :controller

  alias OpenMuWeb.News

  def index(conn, params) do
    page = News.parse_page(params["page"])
    render(conn, :index, page: page, news: News.list_page(page))
  end

  def show(conn, %{"id" => id}) do
    render(conn, :show, article: News.get_article(id))
  end
end
