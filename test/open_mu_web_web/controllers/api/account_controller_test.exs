defmodule OpenMuWebWeb.Api.AccountControllerTest do
  use OpenMuWebWeb.ConnCase

  @valid %{
    "LoginName" => "apiuser1",
    "EMail" => "apiuser1@example.com",
    "Password" => "password1",
    "RepeatPassword" => "password1"
  }

  defp post_raw(conn, path, body, content_type \\ "application/json") do
    conn |> put_req_header("content-type", content_type) |> post(path, body)
  end

  describe "POST /api/account/register" do
    test "201 on success", %{conn: conn} do
      conn = post(conn, ~p"/api/account/register", @valid)
      assert response(conn, 201) == ~s({"user":"apiuser1","message":"User created succesfully!"})
    end

    test "409 for taken login name / email", %{conn: conn} do
      assert conn
             |> post(~p"/api/account/register", %{@valid | "LoginName" => "test1"})
             |> response(409) ==
               ~s({"user":null,"message":"Username already in use!"})
    end

    test "500 with the ZodError, byte-identical to the Next.js response", %{conn: conn} do
      golden = File.read!("test/fixtures/next_register_zod_error.json")
      body = ~s({"LoginName":"ab","EMail":"x","Password":"1","RepeatPassword":"2"})
      assert conn |> post_raw(~p"/api/account/register", body) |> response(500) == golden
    end

    test "invalid or empty JSON, any content type", %{conn: conn} do
      expected = ~s({"message":"Something went wrong!","error":{}})
      assert conn |> post_raw(~p"/api/account/register", "nojson") |> response(500) == expected
      assert build_conn() |> post_raw(~p"/api/account/register", "") |> response(500) == expected

      # like req.json(): the body is parsed even when sent as text/plain
      conn =
        build_conn() |> post_raw(~p"/api/account/register", Jason.encode!(@valid), "text/plain")

      assert response(conn, 201)
    end
  end

  describe "PUT /api/account/changepassword" do
    test "changes the password of the logged-in account only; body name is ignored (R1)", %{
      conn: conn
    } do
      other = OpenMuWeb.Repo.get_by!(OpenMuWeb.OpenMU.Account, login_name: "test2").password_hash

      conn =
        conn
        |> log_in("test1")
        |> put(~p"/api/account/changepassword", %{
          "name" => "test2",
          "oldPassword" => "test1",
          "newPassword" => "password2",
          "repeatNewPassword" => "password2"
        })

      assert response(conn, 200) == ~s({"message":"Password changes successfully"})
      assert {:ok, _} = OpenMuWeb.Accounts.authenticate("test1", "password2")

      assert OpenMuWeb.Repo.get_by!(OpenMuWeb.OpenMU.Account, login_name: "test2").password_hash ==
               other
    end

    test "validation messages", %{conn: conn} do
      conn = log_in(conn, "test1")

      cases = [
        {%{"oldPassword" => "a", "newPassword" => "a", "repeatNewPassword" => "a"},
         "New password and old password are the same!"},
        {%{"oldPassword" => "test1", "newPassword" => "b", "repeatNewPassword" => "c"},
         "New password and Reapeat password should match!"},
        {%{"oldPassword" => "wrong", "newPassword" => "b", "repeatNewPassword" => "b"},
         "The old password you inserted isn't correct!"},
        {%{}, "New password and old password are the same!"}
      ]

      for {body, message} <- cases do
        assert conn |> put(~p"/api/account/changepassword", body) |> json_response(400) == %{
                 "message" => message
               }
      end

      assert conn
             |> put_req_header("content-type", "application/json")
             |> put(~p"/api/account/changepassword", "nojson")
             |> json_response(400) ==
               %{"message" => "There was a problem try again later"}
    end

    test "anonymous: field checks first, then 'There was a problem'", %{conn: conn} do
      assert conn
             |> put(~p"/api/account/changepassword", %{
               "oldPassword" => "a",
               "newPassword" => "a",
               "repeatNewPassword" => "a"
             })
             |> json_response(400) == %{
               "message" => "New password and old password are the same!"
             }

      assert build_conn()
             |> put(~p"/api/account/changepassword", %{
               "oldPassword" => "a",
               "newPassword" => "b",
               "repeatNewPassword" => "b"
             })
             |> json_response(400) == %{"message" => "There was a problem try again later"}
    end
  end

  describe "GET /api/auth/session" do
    test "NextAuth-shaped session", %{conn: conn} do
      body = conn |> log_in("testgm") |> get(~p"/api/auth/session") |> response(200)

      assert body =~
               ~r/^\{"user":\{"email":"","username":"testgm","role":"GAME_MASTER"\},"expires":"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z"\}$/
    end

    test "anonymous", %{conn: conn} do
      assert conn |> get(~p"/api/auth/session") |> response(200) == "{}"
    end
  end
end
