defmodule OpenMuWebWeb.NewsControllerTest do
  use OpenMuWebWeb.ConnCase

  import OpenMuWeb.Fixtures

  setup do
    delete_all_news!()

    articles =
      for n <- 1..6 do
        insert_news!(
          title: "News #{n}",
          body: if(n == 2, do: String.duplicate("x", 360), else: "Body #{n}\nsecond   line"),
          author: "testgmDk",
          creation_date: ~N[2026-09-20 10:00:00] |> NaiveDateTime.add(n, :hour)
        )
      end

    %{articles: articles}
  end

  describe "GET / (news list)" do
    test "first page: 4 newest news, next button only", %{conn: conn} do
      html = conn |> get(~p"/") |> html_response(200)

      for n <- 3..6, do: assert(html =~ "News #{n}")
      refute html =~ "News 2"
      # body whitespace is kept verbatim (p { white-space: pre })
      assert html =~ "Body 6\nsecond   line"
      assert html =~ "9/20/2026"
      assert html =~ ~s(href="/?page=1")
      assert html =~ "Next page &gt;"
      refute html =~ "Prev page"
    end

    test "second page: remaining news, prev button, long body truncated", %{conn: conn} do
      html = conn |> get(~p"/?page=1") |> html_response(200)

      assert html =~ "News 2"
      assert html =~ "News 1"
      refute html =~ "News 3"
      assert html =~ String.duplicate("x", 350) <> "...  Click to read all."
      refute html =~ String.duplicate("x", 351)
      assert html =~ ~s(href="/?page=0")
      refute html =~ "Next page"
    end

    test "invalid page falls back to page 0", %{conn: conn} do
      assert conn |> get(~p"/?page=abc") |> html_response(200) =~ "News 6"
    end

    test "news cards link to the detail page", %{conn: conn, articles: articles} do
      html = conn |> get(~p"/") |> html_response(200)
      assert html =~ ~s(href="/news/#{List.last(articles).id}")
    end
  end

  describe "GET /news/:id" do
    test "shows the full body", %{conn: conn, articles: articles} do
      article = Enum.at(articles, 1)
      html = conn |> get(~p"/news/#{article.id}") |> html_response(200)

      assert html =~ "News 2"
      assert html =~ String.duplicate("x", 360)
      refute html =~ "Click to read all."
      assert html =~ "Return back"
    end

    test "unknown or invalid ids show the not-found message", %{conn: conn} do
      assert conn |> get(~p"/news/#{Ecto.UUID.generate()}") |> html_response(200) =~
               "No News was found!"

      assert conn |> get(~p"/news/not-a-uuid") |> html_response(200) =~ "No News was found!"
    end
  end
end
