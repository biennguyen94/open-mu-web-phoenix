defmodule OpenMuWeb.AdminNewsTest do
  use OpenMuWeb.DataCase, async: true

  import OpenMuWeb.Fixtures

  alias OpenMuWeb.{Accounts, News}
  alias OpenMuWeb.News.Article

  setup do
    {:ok, gm} = Accounts.authenticate("testgm", "testgm")
    {:ok, gm2} = Accounts.authenticate("testgm2", "testgm2")
    {:ok, user} = Accounts.authenticate("test1", "test1")
    %{gm: gm, gm2: gm2, user: user}
  end

  describe "create_article/3" do
    test "author is the account's first GM character by slot", %{gm: gm, gm2: gm2} do
      assert {:ok, %Article{id: id, author: "testgmDk", title: "t", body: "b\nline"}} =
               News.create_article(gm, "t", "b\nline")

      assert %Article{creation_date: %NaiveDateTime{microsecond: {us, 6}}} =
               Repo.get!(Article, id)

      assert rem(us, 1000) == 0, "timestamp(3) precision, like Prisma"
      assert {:ok, %Article{author: "testgm2Sum"}} = News.create_article(gm2, "t", "b")
    end

    test "non-GM accounts and anonymous users are rejected (R3)", %{user: user} do
      assert News.create_article(user, "t", "b") == {:error, :forbidden}
      assert News.create_article(nil, "t", "b") == {:error, :not_logged_in}
    end

    test "title/body must be strings; empty strings are allowed (as before)", %{gm: gm} do
      assert News.create_article(gm, nil, "b") == {:error, :invalid}
      assert News.create_article(gm, 5, "b") == {:error, :invalid}
      assert {:ok, _} = News.create_article(gm, "", "")
    end
  end

  describe "delete_article/2" do
    setup do
      %{article: insert_news!(title: "to delete")}
    end

    test "GM deletes; unknown or malformed ids are not found", %{gm: gm, article: article} do
      assert News.delete_article(gm, article.id) == :ok
      assert Repo.get(Article, article.id) == nil
      assert News.delete_article(gm, article.id) == {:error, :not_found}
      assert News.delete_article(gm, "not-a-uuid") == {:error, :not_found}
    end

    test "non-GM accounts cannot delete (R3)", %{user: user, article: article} do
      assert News.delete_article(user, article.id) == {:error, :forbidden}
      assert News.delete_article(nil, article.id) == {:error, :not_logged_in}
      assert Repo.get(Article, article.id)
    end
  end
end
