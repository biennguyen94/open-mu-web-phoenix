defmodule OpenMuWeb.GameServer.Cache do
  @moduledoc """
  Tiny TTL cache (ETS) for game server results. The process only owns the table;
  reads and writes happen in the caller. Concurrent refreshes are harmless.
  """
  use GenServer

  @table __MODULE__

  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @doc "Returns the cached value for `key`, calling `fun` when missing or older than `ttl_ms`."
  def fetch(_key, ttl_ms, fun) when ttl_ms <= 0, do: fun.()

  def fetch(key, ttl_ms, fun) do
    now = System.monotonic_time(:millisecond)

    case :ets.lookup(@table, key) do
      [{^key, value, stored_at}] when now - stored_at < ttl_ms ->
        value

      _ ->
        value = fun.()
        :ets.insert(@table, {key, value, now})
        value
    end
  end

  @impl true
  def init(nil) do
    :ets.new(@table, [:named_table, :public, read_concurrency: true])
    {:ok, nil}
  end
end
