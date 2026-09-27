defmodule OpenMuWebWeb.CharactersLive do
  @moduledoc """
  `/characters` — character panel (port of `app/characters/page.tsx`,
  `CharactersPage.tsx`, `AddStatsCard.tsx`). Login required (server-side guard).

  Each character card shows Resets / Lvl / Master Lvl and the buttons Reset,
  Add Stats (toggles the stats card, one open at a time), Pk Clear and Reset
  Stats; buttons of disabled operations (empty zen setting) are hidden. The
  operations call `OpenMuWeb.Characters` and toast the same messages as the API.
  Differences: after any successful operation the data is reloaded from the
  database (Next.js refreshed only after reset / reset stats and updated the
  Add Stats card locally).
  """
  use OpenMuWebWeb, :live_view

  import OpenMuWebWeb.SiteComponents, only: [avatar: 1]

  alias OpenMuWeb.{Characters, Float32}
  alias OpenMuWeb.OpenMU.Ids
  alias OpenMuWebWeb.CharacterMessages

  @empty_amounts %{"str" => "0", "agi" => "0", "vit" => "0", "ene" => "0", "lead" => "0"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       open: nil,
       amounts: @empty_amounts,
       reset?: Characters.enabled?(:reset),
       pk_clear?: Characters.enabled?(:pk_clear),
       reset_stats?: Characters.enabled?(:reset_stats)
     )
     |> load_characters()}
  end

  defp load_characters(socket) do
    assign(socket, characters: Characters.list_for_account(socket.assigns.current_account))
  end

  @impl true
  def handle_event("toggle_stats", %{"name" => name}, socket) do
    open = if socket.assigns.open == name, do: nil, else: name
    {:noreply, assign(socket, open: open, amounts: @empty_amounts)}
  end

  def handle_event("amounts", %{"amounts" => amounts}, socket) do
    {:noreply, assign(socket, amounts: Map.merge(@empty_amounts, amounts))}
  end

  def handle_event("add_stats", %{"amounts" => amounts}, socket) do
    name = socket.assigns.open
    result = Characters.add_stats(socket.assigns.current_account, name, parse_amounts(amounts))

    socket =
      if result == :ok,
        do: assign(socket, amounts: @empty_amounts),
        else: assign(socket, amounts: amounts)

    {:noreply, socket |> toast(:add_stats, result) |> load_characters()}
  end

  def handle_event("reset", %{"name" => name}, socket) do
    result = Characters.reset(socket.assigns.current_account, name)
    {:noreply, socket |> toast(:reset, result) |> load_characters()}
  end

  def handle_event("pk_clear", %{"name" => name}, socket) do
    result = Characters.pk_clear(socket.assigns.current_account, name)
    {:noreply, socket |> toast(:pk_clear, result) |> load_characters()}
  end

  def handle_event("reset_stats", %{"name" => name}, socket) do
    result = Characters.reset_stats(socket.assigns.current_account, name)
    socket = if result == :ok, do: assign(socket, open: nil), else: socket
    {:noreply, socket |> toast(:reset_stats, result) |> load_characters()}
  end

  defp toast(socket, op, result) do
    {_status, message} = CharacterMessages.response(op, result)
    put_flash(socket, if(result == :ok, do: :info, else: :error), message)
  end

  # `+e.target.value` in AddStatsCard.tsx: an empty input counts as 0.
  defp parse_amounts(amounts) do
    Map.new(@empty_amounts, fn {key, _} ->
      raw = String.trim(Map.get(amounts, key) || "")

      value =
        case Integer.parse(raw) do
          {int, ""} -> int
          _ when raw == "" -> 0
          _ -> :invalid
        end

      {key, value}
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} sidebar={@sidebar} current_account={@current_account}>
      <div class="flex flex-col gap-3 mx-auto w-full px-20">
        <h1
          :if={@characters == []}
          class="text-primary text-xl p-2 bg-secondary/[.2] w-fit px-3 rounded-lg self-center"
        >
          There are no created characters at the moment
        </h1>
        <div :for={c <- @characters} id={"character-#{c.name}"}>
          <div class="p-4 bg-secondary/[0.2] rounded-lg flex gap-2 justify-between">
            <div class="flex flex-col text-primary">
              <p class="text-xl text-primary" phx-no-format><.avatar class_id={c.character_class_id} width="40" class="inline-block rounded-lg shadow-lg shadow-slate-600" /> {c.name} </p>
              <p class="mt-3" phx-no-format> Resets: <span class=" font-semibold ml-1 text-primary">{Float32.display(c.resets)}</span></p>
              <p phx-no-format>Lvl: <span class=" font-semibold ml-1 text-primary">{Float32.display(c.lvl)}</span></p>
              <p phx-no-format>Master Lvl: <span class=" font-semibold ml-1 text-primary">{Float32.display(c.masterlvl)}</span></p>
            </div>
            <div class="flex flex-col">
              <div class="flex justify-between mr-2 gap-2">
                <button
                  :if={@reset?}
                  type="button"
                  phx-click="reset"
                  phx-value-name={c.name}
                  class="h-fit bg-primary/[0.1] p-2 rounded-lg px-4 shadow-md shadow-slate-400 text-slate-800 font-sans hover:bg-secondary/[0.5]"
                >
                  <img
                    src={~p"/images/account/reset.png"}
                    width="25"
                    alt="reset_icon"
                    class="inline-block mb-1"
                  /> Reset
                </button>
                <button
                  type="button"
                  phx-click="toggle_stats"
                  phx-value-name={c.name}
                  class="h-fit bg-primary/[0.2] p-2 rounded-lg px-4 shadow-md shadow-slate-400 text-slate-800 font-sans hover:bg-secondary/[0.5]"
                >
                  <img
                    src={~p"/images/account/add-stats.png"}
                    width="25"
                    alt="add_stats_icon"
                    class="inline-block mb-1"
                  /> Add Stats
                </button>
                <button
                  :if={@pk_clear?}
                  type="button"
                  phx-click="pk_clear"
                  phx-value-name={c.name}
                  class="h-fit bg-primary/[0.3] p-2 rounded-lg px-4 shadow-md shadow-slate-400 text-slate-800 font-sans hover:bg-secondary/[0.5]"
                >
                  <img
                    src={~p"/images/account/clear-pk.png"}
                    width="25"
                    alt="add_stats_icon"
                    class="inline-block mb-1"
                  /> Pk Clear
                </button>
                <button
                  :if={@reset_stats?}
                  type="button"
                  phx-click="reset_stats"
                  phx-value-name={c.name}
                  class="h-fit bg-primary/[0.4] p-2 rounded-lg px-4 shadow-md shadow-slate-400 text-slate-800 font-sans hover:bg-secondary/[0.5]"
                >
                  <img
                    src={~p"/images/account/reset-stats.png"}
                    width="25"
                    alt="add_stats_icon"
                    class="inline-block mb-1"
                  /> Reset Stats
                </button>
              </div>
            </div>
          </div>
          <.add_stats_card :if={@open == c.name} character={c} amounts={@amounts} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :character, :map, required: true
  attr :amounts, :map, required: true

  defp add_stats_card(assigns) do
    assigns =
      assign(assigns,
        stats: [
          {"Strength", :strength, "str"},
          {"Agility", :agility, "agi"},
          {"Vitality", :vitality, "vit"},
          {"Energy", :energy, "ene"}
        ],
        leadership?: Ids.leadership_class?(assigns.character.character_class_id)
      )

    ~H"""
    <.form
      for={%{}}
      as={:amounts}
      id="add-stats-form"
      phx-change="amounts"
      phx-submit="add_stats"
      class=" px-8 p-3 bg-green-300/[0.2] rounded-md mt-2 gap-3 flex flex-col"
    >
      <div>
        <p class="font-semibold" phx-no-format>Free Points: {@character.level_up_points}</p>
      </div>
      <div class="flex">
        <div class="flex flex-col gap-6">
          <p :for={{label, field, _key} <- @stats} phx-no-format>{label}: <span class="font-semibold ml-2">{Float32.display(Map.get(@character, field))}</span></p>
          <p :if={@leadership?} phx-no-format>Leadership: <span class="font-semibold ml-2">{Float32.display(@character.leadership)}</span></p>
        </div>
        <div class="flex flex-col gap-5 ml-5">
          <input
            :for={
              {_label, _field, key} <-
                @stats ++ if(@leadership?, do: [{"Leadership", :leadership, "lead"}], else: [])
            }
            type="number"
            name={"amounts[#{key}]"}
            value={@amounts[key]}
            placeholder="+"
            class="bg-green-300/[0.2] remove-arrow border-2 placeholder:text-slate-700 w-32 border-green-300/[0.3] rounded-lg text-center focus:outline-none focus:border-2 focus:border-green-300"
          />
        </div>
      </div>
      <button class="bg-green-400/[0.2] w-fit mx-auto p-3 px-4 rounded-lg hover:bg-green-400/[0.3]">
        Add Points
      </button>
    </.form>
    """
  end
end
