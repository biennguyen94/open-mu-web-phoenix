defmodule OpenMuWeb.Float32 do
  @moduledoc """
  Normalizes PostgreSQL `real` (float4) values for output.

  Postgrex decodes float4 exactly (e.g. 0.1 -> 0.10000000149011612) while the
  Next.js app (node-postgres) received the shortest decimal text ("0.1"), and
  JavaScript prints whole numbers without ".0". `normalize/1` reproduces that:
  whole numbers become integers, other values the shortest float4 decimal.
  """

  def normalize(nil), do: nil
  def normalize(value) when is_integer(value), do: value

  def normalize(value) when is_float(value) do
    if value == Float.round(value) and abs(value) < 9.0e15 do
      trunc(value)
    else
      shortest(value)
    end
  end

  defp shortest(value) do
    target = <<value::float-32>>

    Enum.find_value(1..9, value, fn digits ->
      candidate =
        value
        # at least one fractional digit: String.to_float/1 rejects "1e-01"
        |> :erlang.float_to_binary(scientific: max(digits - 1, 1))
        |> String.to_float()

      if <<candidate::float-32>> == target, do: candidate
    end)
  end

  @doc "Formats a normalized value like JavaScript's `String(number)` for display."
  def display(nil), do: ""
  def display(value), do: value |> normalize() |> to_string()
end
