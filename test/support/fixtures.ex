defmodule OpenMuWeb.Fixtures do
  @moduledoc """
  Test data helpers. The test database is a full copy of the OpenMU dev database
  (OpenMU test accounts/characters exist); everything done here runs inside the
  Ecto SQL sandbox and is rolled back after each test.
  """
  import Ecto.Query

  alias OpenMuWeb.News.Article
  alias OpenMuWeb.OpenMU.{Character, Guild, GuildMember, StatAttribute}
  alias OpenMuWeb.Repo

  def character!(name), do: Repo.get_by!(Character, name: name)

  @doc "Sets a StatAttribute value of a character (the row must exist)."
  def set_stat!(name, definition_id, value) do
    %{id: id} = character!(name)

    {1, _} =
      from(sa in StatAttribute,
        where: sa.character_id == ^id and sa.definition_id == ^definition_id
      )
      |> Repo.update_all(set: [value: value])

    :ok
  end

  def update_character!(name, changes) do
    {1, _} = from(c in Character, where: c.name == ^name) |> Repo.update_all(set: changes)
    :ok
  end

  @doc "Inserts a guild and its members (`[{character_name, status}]`)."
  def insert_guild!(name, score, opts \\ []) do
    guild =
      Repo.insert!(%Guild{
        id: Ecto.UUID.generate(),
        name: name,
        score: score,
        logo: opts[:logo],
        notice: opts[:notice]
      })

    for {character_name, status} <- Keyword.get(opts, :members, []) do
      Repo.insert!(%GuildMember{
        id: character!(character_name).id,
        guild_id: guild.id,
        status: status
      })
    end

    guild
  end

  @doc "Inserts a news article with an explicit creation date."
  def insert_news!(attrs) do
    attrs = Map.new(attrs)

    Repo.insert!(%Article{
      id: attrs[:id] || Ecto.UUID.generate(),
      title: attrs[:title] || "Title",
      body: attrs[:body] || "Body",
      author: attrs[:author] || "testgmDk",
      creation_date: usec(attrs[:creation_date] || NaiveDateTime.utc_now())
    })
  end

  defp usec(%NaiveDateTime{microsecond: {us, _}} = dt), do: %{dt | microsecond: {us, 6}}

  def delete_all_news!, do: Repo.delete_all(Article)

  # --- Game server stubs (Req.Test) -------------------------------------------------

  @doc "Game server answers like OpenMU (JSON body, text/plain content type)."
  def stub_game_server_online(players \\ []) do
    body =
      Jason.encode!(
        Jason.OrderedObject.new([
          {"state", "Online"},
          {"players", length(players)},
          {"playersList", players}
        ])
      )

    Req.Test.stub(OpenMuWeb.GameServer, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(200, body)
    end)
  end

  def stub_game_server_status(status_code) do
    Req.Test.stub(OpenMuWeb.GameServer, &Plug.Conn.send_resp(&1, status_code, "error"))
  end

  def stub_game_server_down do
    Req.Test.stub(OpenMuWeb.GameServer, &Req.Test.transport_error(&1, :econnrefused))
  end

  def stub_game_server_body(body) do
    Req.Test.stub(OpenMuWeb.GameServer, &Plug.Conn.send_resp(&1, 200, body))
  end
end
