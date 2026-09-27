defmodule OpenMuWebWeb.PageController do
  @moduledoc "Static pages: Info, Download, Terms and Conditions."
  use OpenMuWebWeb, :controller

  alias OpenMuWeb.Settings

  def info(conn, _params), do: render(conn, :info)

  def download(conn, _params) do
    render(conn, :download,
      google_drive_link: Settings.google_drive_link(),
      mediafire_link: Settings.mediafire_link(),
      mega_link: Settings.mega_link()
    )
  end

  def terms(conn, _params), do: render(conn, :terms)
end
