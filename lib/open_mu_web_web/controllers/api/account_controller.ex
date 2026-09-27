defmodule OpenMuWebWeb.Api.AccountController do
  @moduledoc """
  Account endpoints (ports of `app/api/account/*`):

    * `POST /api/account/register` — 201 `{"user","message"}`, 409 `{"user":null,"message"}`,
      500 `{"message":"Something went wrong!","error":<ZodError | {}>}` (same bodies as Next.js)
    * `PUT /api/account/changepassword` — 200/400 `{"message"}`. Security fix R1: the
      password of the **logged-in** account is changed; the body's `name` is ignored.
  """
  use OpenMuWebWeb, :controller

  import OpenMuWebWeb.Api.ApiJSON

  alias OpenMuWeb.Accounts
  alias OpenMuWeb.Accounts.Registration

  @something_wrong "Something went wrong!"

  def register(%Plug.Conn{private: %{body_parse_error: true}} = conn, _params),
    do: something_went_wrong(conn, object([]))

  def register(conn, _params) do
    # A JSON body that is not an object is kept under "_json" by the parser.
    body = Map.get(conn.body_params, "_json", conn.body_params)

    case Accounts.register(body) do
      {:ok, account} ->
        send_json(
          conn,
          201,
          object([{"user", account.login_name}, {"message", "User created succesfully!"}])
        )

      {:error, :email_taken} ->
        send_json(conn, 409, object([{"user", nil}, {"message", "Email already in use!"}]))

      {:error, :username_taken} ->
        send_json(conn, 409, object([{"user", nil}, {"message", "Username already in use!"}]))

      {:error, {:validation, issues}} ->
        something_went_wrong(conn, Registration.zod_error(issues))

      {:error, _} ->
        something_went_wrong(conn, object([]))
    end
  end

  def change_password(%Plug.Conn{private: %{body_parse_error: true}} = conn, _params),
    do: send_message(conn, 400, Accounts.change_password_message({:error, :invalid}))

  def change_password(conn, params) do
    old_password = params["oldPassword"]
    new_password = params["newPassword"]
    repeat_password = params["repeatNewPassword"]

    result =
      cond do
        # The Next.js route validated these two before looking at the session.
        old_password == new_password ->
          {:error, :same_password}

        new_password != repeat_password ->
          {:error, :repeat_mismatch}

        is_nil(conn.assigns[:current_account]) ->
          {:error, :not_logged_in}

        true ->
          Accounts.change_password(
            conn.assigns.current_account,
            old_password,
            new_password,
            repeat_password
          )
      end

    status = if result == :ok, do: 200, else: 400
    send_message(conn, status, Accounts.change_password_message(result))
  end

  defp something_went_wrong(conn, error),
    do: send_json(conn, 500, object([{"message", @something_wrong}, {"error", error}]))
end
