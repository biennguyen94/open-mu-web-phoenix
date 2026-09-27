defmodule OpenMuWebWeb.NewsComponents do
  @moduledoc """
  News UI ported from `NewsCard.tsx`, `ChangePageButton.tsx` and
  `ReturnToHomeButton.tsx`, `DeleteConfirmationDialog.tsx`. Game Masters get a
  "Delete" button that opens the confirmation dialog (assets/js/app.js); "Yes"
  submits `DELETE /admin/news/:id`.
  """
  use OpenMuWebWeb, :html

  @short_length 350

  @doc "A news card; `short` truncates the body to 350 characters like the home page."
  attr :article, :map, required: true
  attr :short, :boolean, default: false
  attr :gm, :boolean, default: false, doc: "show the Delete button (logged-in Game Master)"

  def news_card(assigns) do
    ~H"""
    <div class="bg-slate-200/[0.3] border-2 border-slate-200/[0.5] rounded-lg p-3 text-primary mt-4 hover:border-secondary/[0.4]">
      <.delete_confirmation_dialog :if={@gm} article={@article} />
      <div class="flex justify-between h-fit">
        <div class="h-fit">
          <h2 class="text-primary text-xl font-semibold">{@article.title}</h2>
        </div>
        <div :if={@gm} class="h-fit ">
          <button
            type="button"
            class=" bg-red-100 hover:bg-red-200/[0.9] p-1 rounded-lg px-2  mx-auto shadow-md text-red-500"
            data-news-delete={"news-delete-#{@article.id}"}
          >
            Delete
          </button>
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

  attr :article, :map, required: true

  defp delete_confirmation_dialog(assigns) do
    ~H"""
    <div
      id={"news-delete-#{@article.id}"}
      class="flex-col p-10 fixed inset-0 bg-slate-50 border-2 mx-auto my-auto w-fit h-fit rounded-md z-20"
      data-news-dialog
      hidden
    >
      <p class="text-primary text-xl" phx-no-format>Are you sure you want to delete this news?</p>
      <div class="flex p-5 justify">
        <.form for={%{}} action={~p"/admin/news/#{@article.id}"} method="delete" class="mx-auto">
          <button class="  bg-red-100 hover:bg-red-200/[0.9] p-1 rounded-lg px-2  mx-auto shadow-md text-red-500">
            Yes
          </button>
        </.form>
        <button
          type="button"
          class="bg-secondary/[0.6] hover:bg-secondary/[0.9] p-1 rounded-lg px-2  mx-auto shadow-md text-primary"
          data-news-cancel
        >
          No
        </button>
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
