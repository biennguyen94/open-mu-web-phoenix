defmodule OpenMuWebWeb.NewsHTML do
  use OpenMuWebWeb, :html

  import OpenMuWebWeb.NewsComponents

  embed_templates "news_html/*"
end
