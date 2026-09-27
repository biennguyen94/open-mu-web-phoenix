defmodule OpenMuWebWeb.Router do
  use OpenMuWebWeb, :router

  import OpenMuWebWeb.Sidebar, only: [assign_sidebar: 2]

  import OpenMuWebWeb.UserAuth,
    only: [fetch_current_account: 2, require_authenticated: 2, require_gm: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OpenMuWebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
  end

  # Sidebar data for controller-rendered pages (LiveViews load it in on_mount).
  pipeline :sidebar do
    plug :assign_sidebar
  end

  # JSON API kept for compatibility (decision D3). Like the Next.js route handlers,
  # responses are JSON whatever the Accept header is.
  pipeline :api do
    plug :put_format, "json"
    # Session cookie (SameSite=Lax) identifies the account, like the NextAuth cookie did.
    plug :fetch_session
    plug :fetch_current_account
  end

  scope "/", OpenMuWebWeb do
    pipe_through [:browser, :sidebar]

    get "/", NewsController, :index
    get "/news/:id", NewsController, :show
    get "/info", PageController, :info
    get "/download", PageController, :download
    get "/terms-and-conditions", PageController, :terms
  end

  scope "/", OpenMuWebWeb do
    pipe_through :browser

    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  live_session :default,
    on_mount: [{OpenMuWebWeb.UserAuth, :mount_current_account}, {OpenMuWebWeb.Sidebar, :default}] do
    scope "/", OpenMuWebWeb do
      pipe_through :browser

      live "/ranking", RankingLive
      live "/register", RegisterLive
    end
  end

  live_session :authenticated,
    on_mount: [{OpenMuWebWeb.UserAuth, :require_authenticated}, {OpenMuWebWeb.Sidebar, :default}] do
    scope "/", OpenMuWebWeb do
      pipe_through [:browser, :require_authenticated]

      live "/account", AccountLive
      live "/characters", CharactersLive
    end
  end

  live_session :game_master,
    on_mount: [{OpenMuWebWeb.UserAuth, :require_gm}, {OpenMuWebWeb.Sidebar, :default}] do
    scope "/", OpenMuWebWeb do
      pipe_through [:browser, :require_gm]

      live "/admin/news", AdminNewsLive
    end
  end

  scope "/", OpenMuWebWeb do
    pipe_through [:browser, :require_gm]

    delete "/admin/news/:id", AdminNewsController, :delete
  end

  scope "/api", OpenMuWebWeb.Api do
    pipe_through :api

    get "/status", StatusController, :show
    get "/characters/ranking/reset", RankingController, :reset
    get "/characters/ranking/killers", RankingController, :killers
    post "/characters/ranking/online", RankingController, :online
    get "/guilds", GuildController, :index
    get "/guilds/:guild_name", GuildController, :show

    get "/auth/session", AuthController, :session
    post "/account/register", AccountController, :register
    put "/account/changepassword", AccountController, :change_password

    post "/characters/addstats", CharacterController, :add_stats
    post "/characters/pkclear", CharacterController, :pk_clear
    post "/characters/reset", CharacterController, :reset
    post "/characters/resetStats", CharacterController, :reset_stats

    post "/admin/news", AdminNewsController, :create
    delete "/admin/news/:id", AdminNewsController, :delete
  end

  if Application.compile_env(:open_mu_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OpenMuWebWeb.Telemetry
    end
  end
end
