defmodule OpenMuWebWeb.AdminNewsLive do
  @moduledoc """
  `/admin/news` — add a news article (port of `app/admin/news/page.tsx` +
  `AddNews.tsx`). Game Masters only, checked server-side (the Next.js page was only
  guarded by `localStorage.role` in the browser — R6).
  """
  use OpenMuWebWeb, :live_view

  alias OpenMuWeb.News

  @empty %{"title" => "", "body" => ""}

  @impl true
  def mount(_params, _session, socket),
    do: {:ok, assign(socket, form: to_form(@empty, as: :news))}

  @impl true
  def handle_event("change", %{"news" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: :news))}
  end

  def handle_event("add", %{"news" => params}, socket) do
    case News.create_article(socket.assigns.current_account, params["title"], params["body"]) do
      {:ok, _article} ->
        {:noreply,
         socket
         |> put_flash(:info, "News added successfully")
         |> assign(form: to_form(@empty, as: :news))}

      {:error, reason} ->
        message =
          if reason in [:not_logged_in, :forbidden],
            do: "You can't do this!",
            else: "There was a problem try again later"

        {:noreply,
         socket |> put_flash(:error, message) |> assign(form: to_form(params, as: :news))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} sidebar={@sidebar} current_account={@current_account}>
      <div class="flex flex-col mt-10 items-center w-full">
        <div class="flex flex-col mt-10 items-center w-full">
          <h1 class="font-bold text-2xl text-primary mb-8">Add News</h1>
          <.form
            for={@form}
            id="news-form"
            class="flex flex-col gap-10 w-10/12"
            phx-change="change"
            phx-submit="add"
          >
            <input
              type="text"
              name={@form[:title].name}
              value={@form[:title].value}
              maxlength="200"
              placeholder="title"
              class="text-center bg-inherit border-b-2 border-slate-400 text-lg p-2 outline-none text-primary invalid:border-red-500"
            />
            <textarea
              name={@form[:body].name}
              maxlength="3000"
              class="text-center bg-inherit border-2 border-slate-400 text-lg p-2 outline-none text-primary invalid:border-red-500"
            >{@form[:body].value}</textarea>
            <button class="mt-4 bg-secondary/[0.6] hover:bg-secondary/[0.9] p-3 rounded-lg w-44 mx-auto shadow-xl text-xl text-primary">
              Add News
            </button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
