defmodule OpenMuWebWeb.CharacterMessages do
  @moduledoc """
  Messages and HTTP statuses of the character operations, per Next.js route
  (`app/api/characters/{addstats,pkclear,reset,resetStats}`). Shared by the JSON
  API and the `/characters` LiveView toasts. Note the inconsistent statuses of the
  original (e.g. "You can't do this!" is 500 on addstats/pkclear, 400 elsewhere).
  """

  @type op :: :add_stats | :pk_clear | :reset | :reset_stats

  @success %{
    add_stats: "Character points added succesfuly",
    pk_clear: "PkClear successfully",
    reset: "Character reseted successfully!",
    reset_stats: "Points were reseted succesffuly"
  }

  # Message of an unexpected failure (the `catch` of each route).
  @failure %{
    add_stats: "There was a problem try again later",
    pk_clear: "There was a problem try again later",
    reset: "There was a problem while resetting your character",
    reset_stats: "There was a problem while reseting the points"
  }

  @doc "`{status, message}` for the result of an operation."
  @spec response(op(), :ok | {:error, term()}) :: {pos_integer(), String.t()}
  def response(op, :ok), do: {200, Map.fetch!(@success, op)}
  def response(_op, {:error, :disabled}), do: {400, "Function disabled"}

  def response(op, {:error, :not_logged_in}) when op in [:add_stats, :pk_clear],
    do: {500, "You can't do this!"}

  def response(op, {:error, :forbidden}) when op in [:add_stats, :pk_clear],
    do: {500, "You can't do this!"}

  def response(:reset, {:error, :forbidden}), do: {400, "You can't do this! Try to Login again."}

  def response(_op, {:error, reason}) when reason in [:not_logged_in, :forbidden],
    do: {400, "You can't do this!"}

  def response(_op, {:error, :online}), do: {400, "Disconnect from your account!"}

  def response(_op, {:error, :server_unreachable}),
    do: {500, "Couldn't reach the server, try again later"}

  def response(:add_stats, {:error, :not_enough_points}),
    do: {400, "You don't have enough points!"}

  def response(:reset, {:error, {:not_eligible, level, max_reset}}),
    do: {400, "You aren't lvl #{level} or you are at maximum reset #{max_reset}"}

  def response(_op, {:error, {:not_enough_zen, zen}}),
    do: {400, "You don't have enough zen: #{zen}"}

  def response(op, {:error, _}), do: {400, Map.fetch!(@failure, op)}
end
