defmodule Exmud.Account.Util do
  @moduledoc false

  @spec normalize_changeset_errors(Ecto.Changeset.t()) ::
          [
            {:password_breached, times :: integer()}
            | :duplicate_username
            | :duplicate_email
            | :email_invalid
            | :duplicate_nickname
          ]
  def normalize_changeset_errors(changeset) do
    Enum.map(changeset.errors, fn {field, {message, options}} ->
      normalize_field_error(field, message, options)
    end)
  end

  defp normalize_field_error(:email, "has already been taken", _options) do
    :email_taken
  end

  defp normalize_field_error(:email, _, _options) do
    :email_invalid
  end

  defp normalize_field_error(:username, "has already been taken", _options) do
    :username_taken
  end

  defp normalize_field_error(:username, "should be at least" <> _, _options) do
    :username_too_short
  end

  defp normalize_field_error(:username, "should be at most" <> _, _options) do
    :username_too_long
  end

  defp normalize_field_error(:nickname, "has already been taken", _options) do
    :nickname_taken
  end

  defp normalize_field_error(:nickname, "should be at least" <> _, _options) do
    :nickname_too_short
  end

  defp normalize_field_error(:nickname, "should be at most" <> _, _options) do
    :nickname_too_long
  end

  defp normalize_field_error(:password, "should be at least" <> _, _options) do
    :password_too_short
  end

  defp normalize_field_error(:password, "should be at most" <> _, _options) do
    :password_too_long
  end

  defp normalize_field_error(:password, {:breached, n}, _options) do
    {:password_breached, n}
  end
end
