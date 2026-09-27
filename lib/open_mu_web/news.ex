defmodule OpenMuWeb.News do
  @moduledoc """
  News (`data."OpenMuWeb_News"`). Port of `News.tsx` / `news/[id]/page.tsx`.
  """
  import Ecto.Query

  alias OpenMuWeb.News.Article
  alias OpenMuWeb.Repo

  @per_page 4

  # Same pattern as app/news/[id]/page.tsx (versions 1-5, RFC variant).
  @uuid_regex ~r/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/

  def per_page, do: @per_page

  @doc """
  Returns the news of a page (4 per page, newest first). Negative pages count
  as page 0, like the Next.js app.
  """
  def list_page(page) when is_integer(page) do
    page = max(page, 0)

    Article
    |> order_by(desc: :creation_date)
    |> offset(^(page * @per_page))
    |> limit(^@per_page)
    |> Repo.all()
  end

  @doc "Returns the article with the given id, or nil (also for ids that are not UUIDs)."
  def get_article(id) when is_binary(id) do
    if Regex.match?(@uuid_regex, id), do: Repo.get(Article, id), else: nil
  end

  def get_article(_), do: nil

  @doc """
  Parses the `page` query parameter. Anything that is not an integer >= 0 is page 0.
  """
  def parse_page(value) when is_binary(value) do
    case Integer.parse(value) do
      {page, ""} when page >= 0 -> page
      _ -> 0
    end
  end

  def parse_page(_), do: 0
end
