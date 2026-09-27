defmodule OpenMuWebWeb.RankingLive do
  @moduledoc """
  `/ranking` — port of `app/ranking/page.tsx` and its tables. Tabs (Top Characters,
  Top Killers, Top Guilds, Online Players) are kept in the URL (`?tab=`); the
  default tab is Top Characters, like the Next.js page. Hovering a guild row shows
  the member popup at the mouse position (`GuildPopUp.tsx`).
  """
  use OpenMuWebWeb, :live_view

  import OpenMuWebWeb.SiteComponents, only: [avatar: 1]

  alias OpenMuWeb.{Float32, GameServer, Guilds, Rankings}
  alias OpenMuWeb.OpenMU.Ids

  @tabs [
    {"topLevel", "Top Characters"},
    {"topKillers", "Top Killers"},
    {"topGuilds", "Top Guilds"},
    {"online", "Online Players"}
  ]
  @tab_ids Enum.map(@tabs, &elem(&1, 0))

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, tabs: @tabs, rows: [], popup: nil, page_title: nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tab = if params["tab"] in @tab_ids, do: params["tab"], else: "topLevel"
    {:noreply, socket |> assign(tab: tab, popup: nil) |> load_rows(tab)}
  end

  @impl true
  def handle_event("select", %{"tab" => tab}, socket) when tab in @tab_ids do
    {:noreply, push_patch(socket, to: ~p"/ranking?#{[tab: tab]}")}
  end

  def handle_event("guild_hover", %{"index" => index, "x" => x, "y" => y}, socket) do
    case Enum.at(socket.assigns.rows, index) do
      nil ->
        {:noreply, socket}

      guild ->
        members = guild.name |> Guilds.members() |> Enum.reverse()

        socket =
          if members == [], do: put_flash(socket, :error, "There was en error!"), else: socket

        {:noreply,
         assign(socket, popup: %{index: index, x: x, y: y, name: guild.name, members: members})}
    end
  end

  def handle_event("guild_leave", _params, socket), do: {:noreply, assign(socket, popup: nil)}

  defp load_rows(socket, "topLevel"), do: assign(socket, rows: Rankings.top_characters(50))
  defp load_rows(socket, "topKillers"), do: assign(socket, rows: Rankings.top_killers(30))
  defp load_rows(socket, "topGuilds"), do: assign(socket, rows: Guilds.top(30))

  defp load_rows(socket, "online") do
    case GameServer.status() do
      {:ok, status} ->
        names = status |> GameServer.players_list() |> Enum.filter(&is_binary/1)
        assign(socket, rows: Rankings.online_players(names))

      {:error, _} ->
        socket
        |> assign(rows: [])
        |> put_flash(
          :error,
          "There was a problem trying to find the online users. Try again later."
        )
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} sidebar={@sidebar} current_account={@current_account}>
      <div class="flex flex-col mb-2 w-full px-20">
        <h2 class="text-primary text-lg">Top Rankings</h2>
        <hr class="border-t-2 border-t-primary" />
        <div class="mt-2 flex gap-1">
          <button
            :for={{id, label} <- @tabs}
            id={id}
            type="button"
            class="border-primary border-2 py-1 px-3 font-thin text-primary"
            phx-click="select"
            phx-value-tab={id}
          >
            {label}
          </button>
        </div>
        <.top_characters :if={@tab == "topLevel"} rows={@rows} />
        <.top_guilds :if={@tab == "topGuilds"} rows={@rows} popup={@popup} />
        <.top_killers :if={@tab == "topKillers"} rows={@rows} />
        <.online_players :if={@tab == "online"} rows={@rows} />
      </div>
    </Layouts.app>
    """
  end

  defp top_characters(assigns) do
    ~H"""
    <div class="w-full flex flex-col gap-5 mx-auto mt-2">
      <table class="w-full m-0">
        <thead class="m-5 bg-primary text-white">
          <tr class="mb-5">
            <th class="text-start pl-3 pb-3.5">#</th>
            <th class="text-start pb-3.5">Name</th>
            <th class="pb-3.5">Level</th>
            <th class="pb-3.5">Master Level</th>
            <th class="pb-3.5">Resets</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{c, i} <- Enum.with_index(@rows, 1)} class="border-b-2 border-slate-300">
            <td class="text-start text-slate-700 font-bold pb-3.5 pl-3 pt-3">{i}</td>
            <td class="text-start font-normal text-primary pb-3.5 pt-3">
              <.avatar
                class_id={c.character_class_id}
                width="35"
                class="inline-block mr-2 rounded-lg shadow-lg shadow-black"
              /> {c.name}
            </td>
            <td class="pb-3.5 font-normal text-center text-primary text-lg pt-3">
              {Float32.display(c.lvl)}
            </td>
            <td class="pb-3.5 font-normal text-center text-primary text-lg pt-3">
              {Float32.display(c.masterlvl)}
            </td>
            <td class="pb-3.5 font-normal text-primary text-center pt-3">
              {Float32.display(c.resets)}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp top_killers(assigns) do
    ~H"""
    <div class="w-full flex flex-col gap-5 mx-auto mt-2">
      <table class="w-full m-0">
        <thead class="p-3 bg-primary text-white">
          <tr>
            <th class="text-start pl-3 pb-3">#</th>
            <th class="text-start pb-3">Name</th>
            <th class="pb-3">Kill Count</th>
            <th class="pb-3">Location</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{c, i} <- Enum.with_index(@rows, 1)} class="border-b-2 border-slate-300">
            <td class="text-start text-slate-700 font-bold pb-3.5 pl-3 pt-3">{i}</td>
            <td class="text-start font-normal text-primary pb-3.5 pt-3">
              <.avatar
                class_id={c.character_class_id}
                width="35"
                class="inline-block rounded-lg shadow-lg shadow-black"
              /> {c.name}
            </td>
            <td class="pb-3.5 font-semibold text-center text-red-500 text-lg pt-3">
              {c.player_kill_count}
            </td>
            <td class="text-center font-normal text-primary pb-3.5 pt-3">
              {Ids.map_name(c.current_map_id)}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp top_guilds(assigns) do
    ~H"""
    <div class="w-full flex flex-col gap-5 mx-auto mt-3">
      <table>
        <thead class="p-3 bg-primary text-white text-center">
          <tr>
            <th class="font-bold text-white pb-3 pl-3 text-start"></th>
            <th class="font-bold text-white pb-3 text-center">Name</th>
            <th class="font-bold text-white pb-3 text-center">Score</th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={{g, i} <- Enum.with_index(@rows)}
            id={"guild-#{i}"}
            class="border-b-2 border-slate-300"
            phx-hook=".GuildHover"
            data-index={i}
          >
            <th class="text-slate-700 text-lg font-semibold pb-1.5 text-start pl-5 pt-3">{i + 1}</th>
            <th class="text-primary text-lg pb-1.5 pt-3">{g.name}</th>
            <th class="text-primary text-lg pb-1.5 pt-3">
              {g.score}
              <.guild_popup :if={@popup && @popup.index == i} popup={@popup} />
            </th>
          </tr>
        </tbody>
      </table>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".GuildHover">
        export default {
          mounted() {
            this.el.addEventListener("mouseenter", e => {
              this.pushEvent("guild_hover", {index: Number(this.el.dataset.index), x: e.clientX, y: e.clientY})
            })
            this.el.addEventListener("mouseleave", () => this.pushEvent("guild_leave", {}))
          }
        }
      </script>
    </div>
    """
  end

  defp guild_popup(assigns) do
    ~H"""
    <div
      class="flex flex-col bg-slate-100 z-10 fixed shadow-md"
      style={"left: #{@popup.x}px; top: #{@popup.y}px"}
    >
      <div class="text-2xl font-semibold text-primary p-3 text-center bg-gradient-to-r from-oceanic via-secondary/[0.5] to-oceanic mb-2">
        {@popup.name}
      </div>
      <div class="flex gap-2 text-base w-64 mb-2">
        <div class="w-1/2">Name</div>
        <div class="w-1/2">Status</div>
      </div>
      <div :for={m <- @popup.members} class="flex gap-2 w-full text-primary text-base font-light my-1">
        <div class="w-1/2">{m.name}</div>
        <div class="w-1/2">{Guilds.position_label(m.status)}</div>
      </div>
    </div>
    """
  end

  defp online_players(assigns) do
    ~H"""
    <div class="w-full flex flex-col gap-5 mx-auto mt-2">
      <table class="w-full m-0">
        <thead class="m-5 bg-primary text-white">
          <tr class="mb-5">
            <th class="text-start pl-3 pb-3.5">#</th>
            <th class="text-start pb-3.5">Name</th>
            <th class="pb-3.5">Map</th>
            <th class="pb-3.5">Position</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{c, i} <- Enum.with_index(@rows, 1)} class="border-b-2 border-slate-300">
            <td class="text-start text-slate-700 font-bold pb-3.5 pl-3 pt-3">{i}</td>
            <td class="text-start font-normal text-primary pb-3.5 pt-3">
              <.avatar
                class_id={c.character_class_id}
                width="35"
                class="inline-block mr-2 rounded-lg shadow-lg shadow-black"
              /> {c.name}
            </td>
            <td class="pb-3.5 font-normal text-center text-primary text-lg pt-3">
              {Ids.map_name(c.current_map_id)}
            </td>
            <td class="pb-3.5 font-normal text-center text-primary text-lg pt-3">
              {c.position_x}, {c.position_y}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
