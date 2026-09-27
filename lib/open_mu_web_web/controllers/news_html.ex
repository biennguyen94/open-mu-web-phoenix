defmodule OpenMuWebWeb.NewsHTML do
  use OpenMuWebWeb, :html

  import OpenMuWebWeb.NewsComponents

  embed_templates "news_html/*"

  defp gm?(%{gm?: true}), do: true
  defp gm?(_), do: false
end
