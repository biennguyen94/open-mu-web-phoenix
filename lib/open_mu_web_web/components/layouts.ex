defmodule OpenMuWebWeb.Layouts do
  @moduledoc """
  Layouts of the site. `app/1` reproduces `app/layout.tsx` of the Next.js app:
  navbar, secondary nav, banners + login/user panel, page content next to the
  sidebar, footer and flash messages (the replacement for react-toastify).
  """
  use OpenMuWebWeb, :html

  import OpenMuWebWeb.SiteComponents

  embed_templates "layouts/*"

  @doc """
  Renders the site layout. Invoke it from every template / LiveView:

      <Layouts.app flash={@flash}>
        <div class="px-20 w-full">...</div>
      </Layouts.app>

  `current_account` (Phase 3) and `sidebar` (Phase 2) are optional so pages
  render before those features exist.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_account, :map, default: nil, doc: "the logged-in account, if any"

  attr :sidebar, :map,
    default: %{},
    doc: "sidebar data: :server_status, :top_characters, :top_guilds"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <.navbar />
    <.secondary_nav />
    <div class="w-[1250px] pb-10 justify-center content-center mt-[120px] bg-oceanic/[0.7] z-10 shadow-2xl shadow-slate-600 -mb-52">
      <.section1 current_account={@current_account} />
      <div class="w-full h-2/3 flex justify-between gap-2">
        {render_slot(@inner_block)}
        <.sidebar
          server_status={@sidebar[:server_status]}
          top_characters={@sidebar[:top_characters] || []}
          top_guilds={@sidebar[:top_guilds] || []}
        />
      </div>
    </div>
    <.site_footer />
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group (top-right, like the react-toastify container).

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" class="fixed top-4 right-4 z-50 flex flex-col gap-2">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
