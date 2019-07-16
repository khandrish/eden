defmodule Exmud.Util do
  @moduledoc """
  Helper functions.
  """

  def changeset_has_error?(changeset = %Ecto.Changeset{}, field) when is_atom(field) do
    Keyword.has_key?(changeset.errors, field)
  end

  def extract_and_normalize_changeset_errors(changeset = %Ecto.Changeset{}) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def transform_normalized_changeset_errors_for_logging(errors) when is_map(errors) do
    errors
    |> Stream.flat_map(fn {field, errors} ->
      Enum.map(errors, fn error_string ->
        "#{field}: #{error_string}"
      end)
    end)
    |> Enum.join("; ")
  end
end
