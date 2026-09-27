defmodule OpenMuWeb.NewsTest do
  use OpenMuWeb.DataCase, async: true

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.News

  setup do
    delete_all_news!()

    articles =
      for n <- 1..6 do
        insert_news!(
          title: "News #{n}",
          creation_date: ~N[2026-09-20 10:00:00] |> NaiveDateTime.add(n, :hour)
        )
      end

    %{articles: articles}
  end

  test "list_page/1 returns 4 news per page, newest first" do
    assert Enum.map(News.list_page(0), & &1.title) == ["News 6", "News 5", "News 4", "News 3"]
    assert Enum.map(News.list_page(1), & &1.title) == ["News 2", "News 1"]
    assert News.list_page(2) == []
  end

  test "negative pages are page 0" do
    assert Enum.map(News.list_page(-3), & &1.title) == ["News 6", "News 5", "News 4", "News 3"]
  end

  test "parse_page/1" do
    assert News.parse_page("2") == 2
    assert News.parse_page("0") == 0
    assert News.parse_page("-1") == 0
    assert News.parse_page("abc") == 0
    assert News.parse_page("1.5") == 0
    assert News.parse_page(nil) == 0
  end

  test "get_article/1 finds by UUID and rejects non-UUID ids", %{articles: [first | _]} do
    assert News.get_article(first.id).title == "News 1"
    assert News.get_article("not-a-uuid") == nil
    # not RFC version 1-5 -> rejected by the same regex as the Next.js page
    assert News.get_article("aaaaaaaa-0000-0000-8000-000000000001") == nil
    assert News.get_article(Ecto.UUID.generate()) == nil
  end

  test "database defaults fill id and creationDate (website-owned table)" do
    {1, [row]} =
      Repo.insert_all("OpenMuWeb_News", [%{title: "t", body: "b", author: "a"}],
        prefix: "data",
        returning: [:id, :creationDate]
      )

    assert is_binary(row.id)
    assert %NaiveDateTime{} = row.creationDate
  end
end
