defmodule OpenMuWeb.Accounts.Registration do
  @moduledoc """
  Validation of the registration payload, reproducing the zod schema of
  `app/api/account/register/route.ts` (zod v4) including its issue list, which the
  API returns inside `{"message":"Something went wrong!","error":{"name":"ZodError",...}}`.

      LoginName      string, min 4 "Username is required", max 10 "Username must not be longer than 10 characters"
      EMail          string, min 5 "Email is required", max 30 "Email must not be longer than 10 characters" (sic), email "Invalid mail"
      Password       string, min 8 "Password needs at least 8 characters", max 20 "Password needs to be less tha 20 characters"
      RepeatPassword string, min 8 "Password needs at least 8 characters"
      refine         Password === RepeatPassword, path RepeatPassword, "Pasword do not match"

  Zod v4 behaviors reproduced (VERIFIED against the running Next.js app):
  every check of every field is reported (no early abort); a non-string value
  gives `invalid_type` and — for arrays only — the length checks still run with
  origin "array"; the email format check only applies to strings; the refinement
  only runs when no `invalid_type` issue exists; lengths count code points.
  """

  alias Jason.OrderedObject

  # Pattern used by zod v4 `.email()` (reported verbatim in the issue).
  @email_pattern "^(?:[A-Za-z0-9_'+\\-]+\\.)*[A-Za-z0-9_'+\\-]*[A-Za-z0-9_+-]@(?:[A-Za-z0-9][A-Za-z0-9\\-]*\\.)+[A-Za-z]{2,}$"
  @email_regex Regex.compile!(@email_pattern)

  @fields [
    {"LoginName",
     [
       min: {4, "Username is required"},
       max: {10, "Username must not be longer than 10 characters"}
     ]},
    {"EMail",
     [
       min: {5, "Email is required"},
       max: {30, "Email must not be longer than 10 characters"},
       email: "Invalid mail"
     ]},
    {"Password",
     [
       min: {8, "Password needs at least 8 characters"},
       max: {20, "Password needs to be less tha 20 characters"}
     ]},
    {"RepeatPassword", [min: {8, "Password needs at least 8 characters"}]}
  ]

  @doc """
  Validates params (string keys). Returns `{:ok, %{login_name, email, password}}`
  or `{:error, issues}` where issues are ordered JSON objects in zod's format.
  """
  def validate(params) when is_map(params) do
    issues =
      Enum.flat_map(@fields, fn {field, checks} ->
        field_issues(field, Map.get(params, field, :undefined), checks)
      end)

    issues =
      if Enum.any?(issues, &(&1["code"] == "invalid_type")) or
           params["Password"] == params["RepeatPassword"] do
        issues
      else
        issues ++
          [
            OrderedObject.new([
              {"code", "custom"},
              {"path", ["RepeatPassword"]},
              {"message", "Pasword do not match"}
            ])
          ]
      end

    case issues do
      [] ->
        {:ok,
         %{login_name: params["LoginName"], email: params["EMail"], password: params["Password"]}}

      issues ->
        {:error, issues}
    end
  end

  # The body is valid JSON but not an object (array, string, null, ...).
  def validate(other) do
    {:error,
     [
       OrderedObject.new([
         {"expected", "object"},
         {"code", "invalid_type"},
         {"path", []},
         {"message", "Invalid input: expected object, received #{js_type(other)}"}
       ])
     ]}
  end

  @doc ~s|The serialized ZodError (`{"name":"ZodError","message":"<issues, 2-space JSON>"}`).|
  def zod_error(issues) do
    OrderedObject.new([{"name", "ZodError"}, {"message", Jason.encode!(issues, pretty: true)}])
  end

  defp field_issues(field, value, checks) when is_binary(value) do
    length = value |> String.to_charlist() |> length()
    Enum.flat_map(checks, &check(&1, field, "string", length, value))
  end

  defp field_issues(field, value, checks) when is_list(value) do
    [
      invalid_type(field, value)
      | Enum.flat_map(checks, &check(&1, field, "array", length(value), nil))
    ]
  end

  defp field_issues(field, value, _checks), do: [invalid_type(field, value)]

  defp check({:min, {min, message}}, field, origin, length, _value) when length < min do
    [
      OrderedObject.new([
        {"origin", origin},
        {"code", "too_small"},
        {"minimum", min},
        {"inclusive", true},
        {"path", [field]},
        {"message", message}
      ])
    ]
  end

  defp check({:max, {max, message}}, field, origin, length, _value) when length > max do
    [
      OrderedObject.new([
        {"origin", origin},
        {"code", "too_big"},
        {"maximum", max},
        {"inclusive", true},
        {"path", [field]},
        {"message", message}
      ])
    ]
  end

  defp check({:email, message}, field, "string", _length, value) do
    if Regex.match?(@email_regex, value) do
      []
    else
      [
        OrderedObject.new([
          {"origin", "string"},
          {"code", "invalid_format"},
          {"format", "email"},
          {"pattern", "/" <> @email_pattern <> "/"},
          {"path", [field]},
          {"message", message}
        ])
      ]
    end
  end

  defp check(_check, _field, _origin, _length, _value), do: []

  defp invalid_type(field, value) do
    OrderedObject.new([
      {"expected", "string"},
      {"code", "invalid_type"},
      {"path", [field]},
      {"message", "Invalid input: expected string, received #{js_type(value)}"}
    ])
  end

  defp js_type(:undefined), do: "undefined"
  defp js_type(nil), do: "null"
  defp js_type(value) when is_boolean(value), do: "boolean"
  defp js_type(value) when is_number(value), do: "number"
  defp js_type(value) when is_list(value), do: "array"
  defp js_type(value) when is_map(value), do: "object"
  defp js_type(value) when is_binary(value), do: "string"
end
