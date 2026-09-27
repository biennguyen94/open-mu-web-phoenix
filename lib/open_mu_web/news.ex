defmodule OpenMuWeb.News do
  @moduledoc """
  News (`data."OpenMuWeb_News"`). Port of `News.tsx` / `news/[id]/page.tsx` and of
  the admin routes `app/api/admin/news` (create) / `app/api/admin/news/[id]` (delete).
  """
  import Ecto.Query

  alias OpenMuWeb.Accounts.CurrentAccount
  alias OpenMuWeb.News.Article
  alias OpenMuWeb.OpenMU.{Character, Ids}
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

  ## Admin (Game Masters)

  @doc """
  Creates a news article as the logged-in Game Master. The author is the name of
  the account's first Game Master character (lowest `CharacterSlot`).

  Security fix R3: the Next.js route looked for a GM character among *all*
  characters (so any logged-in user could post, signed with some GM's name);
  here the logged-in account itself must own a GM character.

  Like the Next.js route there is no length or emptiness rule (the form has
  `maxlength` 200 / 3000); title and body must be strings.
  Returns `{:ok, %Article{}}` or `{:error, :not_logged_in | :forbidden | :invalid}`.
  """
  def create_article(account, title, body) do
    with {:ok, author} <- gm_author(account),
         :ok <- validate_text(title, body) do
      %Article{
        title: title,
        body: body,
        author: author,
        # Prisma's @default(now()): application time, UTC, millisecond precision (timestamp(3))
        creation_date:
          NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:millisecond) |> to_usec()
      }
      |> Repo.insert()
    end
  end

  @doc """
  Deletes a news article as the logged-in Game Master.
  Returns `:ok` or `{:error, :not_logged_in | :forbidden | :not_found}`.
  """
  def delete_article(account, id) do
    with {:ok, _author} <- gm_author(account),
         {:ok, uuid} <- cast_id(id) do
      case Repo.delete_all(from a in Article, where: a.id == ^uuid) do
        {1, _} -> :ok
        {0, _} -> {:error, :not_found}
      end
    end
  end

  defp gm_author(nil), do: {:error, :not_logged_in}

  defp gm_author(%CurrentAccount{id: account_id}) do
    gm = Ids.game_master_status()

    from(c in Character,
      where: c.account_id == ^account_id and c.character_status == ^gm,
      order_by: c.character_slot,
      limit: 1,
      select: c.name
    )
    |> Repo.one()
    |> case do
      nil -> {:error, :forbidden}
      name -> {:ok, name}
    end
  end

  defp validate_text(title, body) when is_binary(title) and is_binary(body), do: :ok
  defp validate_text(_title, _body), do: {:error, :invalid}

  defp cast_id(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> {:error, :not_found}
    end
  end

  defp to_usec(%NaiveDateTime{microsecond: {us, _}} = dt), do: %{dt | microsecond: {us, 6}}
end
