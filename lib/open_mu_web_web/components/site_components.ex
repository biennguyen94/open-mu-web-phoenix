defmodule OpenMuWebWeb.SiteComponents do
  @moduledoc """
  Site chrome ported from the Next.js layout (`app/layout.tsx` and
  `app/_components/**`): navigation, banner slider, login / user panel, sidebar
  and footer. Markup and Tailwind classes follow the originals for UI parity.

  Note: the global CSS rule `p { white-space: pre }` (from the Next.js app) renders
  whitespace inside `<p>` literally, so keep `<p>` contents on a single line and mark them `phx-no-format`.
  """
  use OpenMuWebWeb, :html

  alias OpenMuWeb.Settings

  @doc "Top navigation (`Navbar.tsx`)."
  def navbar(assigns) do
    ~H"""
    <nav>
      <ul class="flex gap-6 justify-center align-center text-xl text-primary mt-5">
        <li :for={
          {label, path} <- [
            {"HOME", "/"},
            {"INFO", "/info"},
            {"RANKING", "/ranking"},
            {"DOWNLOAD", "/download"}
          ]
        }>
          <.link
            href={path}
            class="hover:underline-offset-4 hover:bg-tertiary/[0.1] p-4 align-middle inline-block"
          >
            {label}
          </.link>
        </li>
      </ul>
    </nav>
    """
  end

  @doc "Download / Register buttons and Discord link (`SecondaryNav.tsx`)."
  def secondary_nav(assigns) do
    assigns = assign(assigns, :discord_link, Settings.discord_link() || "")

    ~H"""
    <div class="mt-[350px] w-[1250px] relative">
      <div class="flex justify-center gap-44">
        <.link
          href="/download"
          class="text-3xl p-7 pr-10 text-teal-900 font-bold bg-secondary/[.7] rounded-[70px] border-4 border-white shadow-xl shadow-slate-500 hover:border-teal-600 inline-flex"
        >
          <img class="mr-1" src={~p"/images/download.png"} alt="downlaod-icons" width="40" />
          <span class=""> Download</span>
        </.link>
        <.link
          href="/register"
          class="text-3xl p-7 pr-10 text-teal-900 font-bold bg-secondary/[.7] rounded-[70px] border-4 border-white shadow-xl shadow-slate-500 hover:border-teal-600 inline-flex"
        >
          <img class="mr-1" src={~p"/images/register.png"} alt="downlaod-icons" width="43" />
          <span class="ml-1 mt-0.5"> Register</span>
        </.link>
      </div>
      <div class="w-fit absolute right-10 mt-10">
        <a href={@discord_link} target="_blank">
          <img src={~p"/images/discord.png"} width="60" alt="discord_logo" />
        </a>
      </div>
    </div>
    """
  end

  @doc "Banner slider (`Banners.tsx`); behavior lives in assets/js/app.js."
  def banners(assigns) do
    ~H"""
    <div id="banners" class="w-[60%] h-[90%] bg-slate-400 relative" data-banner phx-update="ignore">
      <img
        :for={
          {src, index} <-
            Enum.with_index([~p"/images/slider-img-1.jpg", ~p"/images/slider-img-2.jpg"])
        }
        class={["w-full object-cover h-full bg-top", index > 0 && "hidden"]}
        src={src}
        alt="slider 1 mu online"
        data-banner-image
      />
      <button
        type="button"
        class="pt-1 px-3 absolute right-10 top-1/2 text-primary bg-secondary/[.9] rounded-full pb-1 px-2 inline-block font-extrabold border shadow-lg shadow-slate-500 hover:border-primary"
        data-banner-next
      >
        &#10132;
      </button>
    </div>
    """
  end

  @doc """
  Banners + login form or user panel (`Section1.tsx`).

  `current_account` is nil until authentication is implemented (Phase 3).
  """
  attr :current_account, :map, default: nil

  def section1(assigns) do
    ~H"""
    <div class="w-full h-[400px] flex mb-10 justify-between">
      <.banners />
      <div class="w-1/3 h-[90%] flex items-center justify-center">
        <.login_form :if={is_nil(@current_account)} />
        <.user_panel :if={@current_account} current_account={@current_account} />
      </div>
    </div>
    """
  end

  @doc """
  Login form (`LoginForm.tsx`). The `/login` endpoint is implemented in Phase 3.
  """
  def login_form(assigns) do
    ~H"""
    <form class="flex flex-col w-72 gap-7 text-primary text-center" action="/login" method="post">
      <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
      <h3 class="text-2xl">Account Login</h3>
      <input
        type="text"
        name="username"
        minlength="4"
        placeholder="userename"
        class="pb-2 mt-1 bg-inherit focus:outline-none text-center text-xl placeholder:text-slate-500 placeholder:text-xl border-b-2 border-slate-400 invalid:border-red-500"
      />
      <input
        type="password"
        name="password"
        minlength="4"
        placeholder="password"
        class="pb-2 bg-inherit focus:outline-none text-center text-xl placeholder:text-slate-500 placeholder:text-xl border-b-2 border-slate-400 invalid:border-red-500"
      />
      <button class="mt-2 bg-secondary/[0.6] hover:bg-secondary/[0.9] p-3 rounded-lg w-44 mx-auto shadow-xl text-xl text-primary">
        Sign In
      </button>
      <p phx-no-format><.link href="/recoverpassword">Lost password?</.link> | <.link href="/register">Register</.link></p>
    </form>
    """
  end

  @doc """
  Logged-in panel (`UserPanel.tsx`). Expects `current_account` with `:gm?`.
  Wired to real sessions in Phase 3.
  """
  attr :current_account, :map, required: true

  def user_panel(assigns) do
    ~H"""
    <div class="flex flex-col content-start">
      <.link href="/account" class="p-1 pt-2 hover:bg-secondary/[0.2]">
        <p class="text-primary text-xl font-semibold text-start" phx-no-format><img src={~p"/images/account/account.png"} width="30" alt="account_icon" class="inline-block mb-1" /> Account</p>
      </.link>
      <.link href="/characters" class="p-1 pt-2 hover:bg-secondary/[0.2]">
        <p class="text-primary text-xl font-semibold text-start" phx-no-format><img src={~p"/images/account/reset.png"} width="30" alt="character_icon" class="inline-block mb-1" /> Characters</p>
      </.link>
      <.link
        :if={Map.get(@current_account, :gm?)}
        href="/admin/news"
        class="p-1 pt-2 hover:bg-secondary/[0.2]"
      >
        <p class="text-primary text-xl font-semibold text-start" phx-no-format><img src={~p"/images/account/add-news.png"} width="28" alt="add_news_icon" class="inline-block mb-1" /> News</p>
      </.link>
      <.link
        href="/logout"
        method="delete"
        class="mt-10 bg-secondary/[0.6] hover:bg-secondary/[0.9] p-3 rounded-lg w-44 mx-auto shadow-xl text-xl text-primary text-center"
      >
        Sign Out
      </.link>
    </div>
    """
  end

  @doc """
  Sidebar (`ServerStatistics.tsx`, `TopPlayers.tsx`, `TopGuilds.tsx`).

  Data is filled in Phase 2; until then the sidebar renders the same state the
  Next.js app shows when the game server / data are unavailable.
  """
  attr :server_status, :map, default: nil
  attr :top_characters, :list, default: []
  attr :top_guilds, :list, default: []

  def sidebar(assigns) do
    ~H"""
    <div class="flex flex-col w-1/3 h-max gap-2">
      <.server_statistics status={@server_status} />
      <.top_characters characters={@top_characters} />
      <.top_guilds guilds={@top_guilds} />
    </div>
    """
  end

  attr :status, :map, default: nil

  def server_statistics(assigns) do
    ~H"""
    <div class="w-72 h-52 flex flex-col gap-3 align-middle mx-auto">
      <h2 class="text-2xl font-semibold text-primary p-3 text-center rounded-lg bg-gradient-to-r from-oceanic via-secondary/[0.5] to-oceanic">
        Server Statistics
      </h2>
      <div class="flex justify-center text-center flex-col">
        <div class="mt-3">
          <h2 class="text-primary font-semibold text-xl ml-6 inline-block align-text-bottom">
            OpenMUWeb
          </h2>
          <img
            src={if online?(@status), do: ~p"/images/online.png", else: ~p"/images/offline.png"}
            alt="online_status"
            class="inline-block align-top -mt-2"
          />
        </div>
      </div>
      <div class="text-center">
        <p class="text-primary text-lg" phx-no-format>Online Users: <span class="text-xl">{players(@status)}</span></p>
      </div>
    </div>
    """
  end

  attr :characters, :list, default: []

  def top_characters(assigns) do
    ~H"""
    <div class="w-72 flex flex-col gap-5 mx-auto mt-2">
      <h2 class="text-2xl font-semibold text-primary p-3 text-center rounded-lg bg-gradient-to-r from-oceanic via-secondary/[0.5] to-oceanic">
        Characters Ranking
      </h2>
      <table class="w-full m-0">
        <thead>
          <tr>
            <th class="text-start text-primary pb-3">#</th>
            <th class="text-start text-primary pb-3">Name</th>
            <th class="text-primary pb-3">Level</th>
            <th class="text-primary pb-3">Resets</th>
          </tr>
        </thead>
        <tbody class="text-start">
          <tr :for={{c, i} <- Enum.with_index(@characters, 1)}>
            <td class="text-start font-normal text-primary pb-3">{i}</td>
            <td class="text-start font-normal text-primary pb-3">
              <.avatar
                class_id={c.character_class_id}
                width="25"
                class="inline-block rounded-md shadow-md shadow-black"
              /> {c.name}
            </td>
            <td class="pb-3 font-normal text-primary text-center">
              {display(c.lvl)}
              <span class="text-red-500 text-xs align-text-top">{display(c.masterlvl)}</span>
            </td>
            <td class="pb-3 font-normal text-primary text-center">{display(c.resets)}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  attr :guilds, :list, default: []

  def top_guilds(assigns) do
    ~H"""
    <div class="w-72 flex flex-col gap-5 mx-auto mt-3">
      <h2 class="text-2xl font-semibold text-primary p-3 text-center rounded-lg bg-gradient-to-r from-oceanic via-secondary/[0.5] to-oceanic">
        Guilds Ranking
      </h2>
      <table>
        <thead>
          <tr>
            <th class="font-bold pl-3 text-primary pb-4 text-start">#</th>
            <th class="font-bold text-primary pb-4">Name</th>
            <th class="font-bold text-primary pb-4 text-center pl-5">Score</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{g, i} <- Enum.with_index(@guilds, 1)}>
            <td class="font-normal text-primary pb-3 pl-3 text-start">{i}</td>
            <td class="font-normal text-primary pb-3 text-center">{g.name}</td>
            <td class="font-normal text-primary pb-3 pl-5 text-center">{g.score}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc "Footer (`Footer.tsx`)."
  def site_footer(assigns) do
    ~H"""
    <div class="flex w-[1400px] h-[480px] bg-top bg-no-repeat bg-[url('/images/bg-footer.jpg')]">
      <div class="w-1/3 h-[50%] mt-auto">
        <div class="ml-24 mt-12">
          <p class="text-primary mb-7" phx-no-format>© OpenMUWeb</p>
          <p class="text-primary" phx-no-format>This site is is no way associated with <br /> or endorsed by Webzen Inc.</p>
        </div>
      </div>
      <div class="w-1/3 h-[50%] mt-auto">
        <div class="ml-24 mt-12">
          <p class="text-primary mb-7" phx-no-format><.link href="/terms-and-conditions">Terms and Conditions</.link> | <a href="https://discord.com/users/254951048437956610" target="_blank">Contact</a></p>
        </div>
      </div>
      <div class="w-1/3 h-[50%] mt-auto"></div>
    </div>
    """
  end

  @doc "Character avatar by class id (port of `getImage`); renders nothing for unknown classes."
  attr :class_id, :string, required: true
  attr :rest, :global, include: ~w(width)

  def avatar(assigns) do
    assigns = assign(assigns, :src, OpenMuWeb.OpenMU.Ids.class_avatar(assigns.class_id))

    ~H"""
    <img :if={@src} src={@src} alt="character_avatar" {@rest} />
    """
  end

  defp display(value), do: OpenMuWeb.Float32.display(value)

  defp online?(%{state: "Online"}), do: true
  defp online?(_), do: false

  # Same fallback as `{status?.players || 0}` in ServerStatistics.tsx.
  defp players(%{players: players}) when is_number(players) and players != 0, do: players
  defp players(_), do: 0
end
