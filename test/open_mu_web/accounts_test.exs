defmodule OpenMuWeb.AccountsTest do
  use OpenMuWeb.DataCase, async: true

  alias OpenMuWeb.Accounts
  alias OpenMuWeb.Accounts.{CurrentAccount, Registration}
  alias OpenMuWeb.OpenMU.Account

  @valid %{
    "LoginName" => "newuser1",
    "EMail" => "newuser1@example.com",
    "Password" => "password1",
    "RepeatPassword" => "password1"
  }

  describe "authenticate/2" do
    test "accepts OpenMU ($2a$) hashes; OpenMU test accounts use password = login name" do
      assert {:ok, %CurrentAccount{login_name: "test1", gm?: false}} =
               Accounts.authenticate("test1", "test1")

      assert {:ok, %CurrentAccount{login_name: "testgm", gm?: true}} =
               Accounts.authenticate("testgm", "testgm")
    end

    test "rejects wrong passwords, unknown users, empty values and other casing" do
      assert Accounts.authenticate("test1", "wrong") == {:error, :invalid_credentials}
      assert Accounts.authenticate("nobody", "test1") == {:error, :invalid_credentials}
      assert Accounts.authenticate("", "") == {:error, :invalid_credentials}
      assert Accounts.authenticate(nil, "x") == {:error, :invalid_credentials}
      assert Accounts.authenticate("TEST1", "test1") == {:error, :invalid_credentials}
    end
  end

  test "get_current_account/1 loads the account and GM flag; bad ids give nil" do
    id = Repo.get_by!(Account, login_name: "testgm2").id
    assert %CurrentAccount{id: ^id, gm?: true} = Accounts.get_current_account(id)
    assert Accounts.get_current_account(Ecto.UUID.generate()) == nil
    assert Accounts.get_current_account("not-a-uuid") == nil
    assert Accounts.get_current_account(nil) == nil
  end

  describe "register/1" do
    test "creates the same row as the Next.js app" do
      assert {:ok, %Account{id: id}} = Accounts.register(@valid)

      %{rows: [row]} =
        Repo.query!(
          ~s|SELECT "LoginName","EMail","PasswordHash","SecurityCode","State","TimeZone","VaultPassword","IsVaultExtended","VaultId","IsTemplate","LanguageIsoCode","IsBot","RegistrationDate" FROM data."Account" WHERE "Id" = $1|,
          [Ecto.UUID.dump!(id)]
        )

      assert [
               "newuser1",
               "newuser1@example.com",
               "$2b$" <> _ = hash,
               "",
               0,
               0,
               "",
               false,
               nil,
               false,
               "en",
               false,
               %DateTime{}
             ] = row

      assert Bcrypt.verify_pass("password1", hash)
      assert {:ok, _} = Accounts.authenticate("newuser1", "password1")
    end

    test "email is checked before the login name" do
      assert Accounts.register(%{@valid | "LoginName" => "test1"}) == {:error, :username_taken}
      {:ok, _} = Accounts.register(@valid)
      assert Accounts.register(%{@valid | "LoginName" => "other1"}) == {:error, :email_taken}
      assert Accounts.register(%{@valid | "LoginName" => "test1"}) == {:error, :email_taken}
    end

    test "validation errors" do
      assert {:error, {:validation, issues}} =
               Accounts.register(%{@valid | "RepeatPassword" => "password2"})

      assert [%{"code" => "custom", "message" => "Pasword do not match"}] =
               Enum.map(issues, &Map.new(&1.values))
    end
  end

  describe "Registration (zod parity)" do
    test "issue list serializes exactly like the Next.js ZodError" do
      golden =
        File.read!("test/fixtures/next_register_zod_error.json")
        |> Jason.decode!(objects: :ordered_objects)

      {:error, issues} =
        Registration.validate(%{
          "LoginName" => "ab",
          "EMail" => "x",
          "Password" => "1",
          "RepeatPassword" => "2"
        })

      assert Jason.encode!(Registration.zod_error(issues)) == Jason.encode!(golden["error"])
    end

    test "types, arrays and non-object bodies" do
      {:error, issues} =
        Registration.validate(%{"LoginName" => Enum.to_list(1..11), "EMail" => nil})

      codes = Enum.map(issues, &{&1["code"], hd(&1["path"]), &1["message"]})

      assert {"invalid_type", "LoginName", "Invalid input: expected string, received array"} in codes
      assert {"too_big", "LoginName", "Username must not be longer than 10 characters"} in codes
      assert {"invalid_type", "EMail", "Invalid input: expected string, received null"} in codes

      assert {"invalid_type", "Password", "Invalid input: expected string, received undefined"} in codes

      # no refinement when a type error exists
      refute Enum.any?(issues, &(&1["code"] == "custom"))

      assert {:error, [issue]} = Registration.validate([])

      assert issue["path"] == [] and
               issue["message"] == "Invalid input: expected object, received array"
    end

    test "lengths count code points; email pattern like zod" do
      assert {:error, [%{} = issue]} = Registration.validate(%{@valid | "LoginName" => "😀😀"})
      assert issue["code"] == "too_small"

      for bad <- [".a@b.cd", "a..b@c.de", "a@b.c", "a@-b.com", "ab@c.d1"] do
        assert {:error, [%{} = issue]} = Registration.validate(%{@valid | "EMail" => bad})
        assert issue["code"] == "invalid_format"
      end

      for good <- ["a.b@c.de", "o'x@ex.com", "A_B+c-d@EX-1.co.uk"] do
        assert {:ok, _} = Registration.validate(%{@valid | "EMail" => good})
      end
    end
  end

  describe "change_password/4" do
    setup do
      {:ok, account} = Accounts.authenticate("test1", "test1")
      %{account: account}
    end

    test "checks in the Next.js order", %{account: account} do
      assert Accounts.change_password(account, "test1", "test1", "test1") ==
               {:error, :same_password}

      assert Accounts.change_password(account, "test1", "password2", "password3") ==
               {:error, :repeat_mismatch}

      assert Accounts.change_password(account, "wrong", "password2", "password2") ==
               {:error, :wrong_old_password}

      assert Accounts.change_password(account, 123, "password2", "password2") ==
               {:error, :invalid}
    end

    test "changes only the given account (R1)", %{account: account} do
      other_hash = Repo.get_by!(Account, login_name: "test2").password_hash

      assert Accounts.change_password(account, "test1", "password2", "password2") == :ok
      assert {:ok, _} = Accounts.authenticate("test1", "password2")
      assert Accounts.authenticate("test1", "test1") == {:error, :invalid_credentials}
      assert Repo.get_by!(Account, login_name: "test2").password_hash == other_hash
    end

    test "messages" do
      assert Accounts.change_password_message(:ok) == "Password changes successfully"

      assert Accounts.change_password_message({:error, :not_logged_in}) ==
               "There was a problem try again later"
    end
  end
end
