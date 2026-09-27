defmodule OpenMuWebWeb.Api.ApiJSON do
  @moduledoc """
  Helpers for `/api/*` responses. Objects are `Jason.OrderedObject`s so the JSON
  keys come out in the same order as the Next.js responses (see `docs/API.md`).
  """

  @doc "Builds an ordered JSON object from a keyword-like list of `{key, value}`."
  def object(pairs), do: Jason.OrderedObject.new(pairs)

  @doc "Sends `data` as JSON with the given status."
  def send_json(conn, status, data) do
    conn
    |> Plug.Conn.put_status(status)
    |> Phoenix.Controller.json(data)
  end

  @doc ~s|`{"message": message}` with the given status (the Next.js error shape).|
  def send_message(conn, status, message),
    do: send_json(conn, status, object([{"message", message}]))

  @doc """
  Prisma `Bytes` serialized by `JSON.stringify` (a `Uint8Array`) — an object with
  the byte indexes as keys, e.g. `{"0":1,"1":2}` (VERIFIED on the Next.js app).
  """
  def bytes(nil), do: nil

  def bytes(binary) when is_binary(binary) do
    binary
    |> :binary.bin_to_list()
    |> Enum.with_index()
    |> Enum.map(fn {byte, index} -> {Integer.to_string(index), byte} end)
    |> object()
  end
end
