defmodule OpenMuWebWeb.NewsComponents do
  @moduledoc """
  News UI ported from `NewsCard.tsx`, `ChangePageButton.tsx` and
  `ReturnToHomeButton.tsx`. (The GM "Delete" button arrives with admin news, Phase 5.)
  """
  use OpenMuWebWeb, :html

  @short_length 350

  @doc "A news card; `short` truncates the body to 350 characters like the home page."
  attr :article, :map, required: true
  attr :short, :boolean, default: false

  def news_card(assigns) do
    ~H"""
    <div class="bg-slate-200/[0.3] border-2 border-slate-200/[0.5] rounded-lg p-3 text-primary mt-4 hover:border-secondary/[0.4]">
      <div class="flex justify-between h-fit">
        <div class="h-fit">
          <h2 class="text-primary text-xl font-semibold">{@article.title}</h2>
        </div>
      </div>
      <hr class="h-[2px] my-4 bg-slate-50 border-0" />
      <.link href={~p"/news/#{@article.id}"} class="news-body block">
        <p style="line-height: 1" phx-no-format>{body(@article.body, @short)}</p>
      </.link>
      <div class="flex justify-end w-full">
        <p class="text-sm italic" phx-no-format>{date(@article.creation_date)} <span class="text-md"> {@article.author}</span></p>
      </div>
    </div>
    """
  end

  @doc "Previous / next page link (`ChangePageButton.tsx`)."
  attr :page, :integer, required: true
  attr :forward, :boolean, required: true

  def change_page_button(assigns) do
    ~H"""
    <.link
      href={~p"/?#{[page: if(@forward, do: @page + 1, else: @page - 1)]}"}
      class="mt-6 bg-secondary/[0.6] hover:bg-secondary/[0.9] p-1 rounded-lg px-2 mx-auto shadow-xl text-primary"
    >
      {if @forward, do: "Next page >", else: "< Prev page"}
    </.link>
    """
  end

  @doc "`ReturnToHomeButton.tsx`."
  def return_to_home_button(assigns) do
    ~H"""
    <.link
      href={~p"/"}
      class="mt-4 bg-secondary/[0.6] hover:bg-secondary/[0.9] p-2 px-3 rounded-lg mx-auto shadow-xl text-xl text-primary"
    >
      Return back
    </.link>
    """
  end

  # `news.body.length < 350 ? body : body.slice(0, 350).concat("...  Click to read all.")`
  # (JavaScript counts UTF-16 code units; graphemes are used here — identical for
  # the Latin text of news posts.)
  defp body(body, false), do: body

  defp body(body, true) do
    if String.length(body) < @short_length,
      do: body,
      else: String.slice(body, 0, @short_length) <> "...  Click to read all."
  end

  # `creationDate.toLocaleDateString()` rendered with the en-US format (M/D/YYYY)
  # on the stored (UTC) date.
  defp date(%NaiveDateTime{year: y, month: m, day: d}), do: "#{m}/#{d}/#{y}"
end
