defmodule Exmud.Util do
  @moduledoc """
  Helper functions.
  """

  import Ecto.Changeset

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

  def get_module_docs(module) do
    module
    |> Code.fetch_docs()
    |> elem(4)
    |> Map.get("en")
  end

  def validate_json(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _field, json_string ->
      case Jason.decode(json_string) do
        {:ok, _} -> []
        {:error, _} -> [{field, options[:message] || "invalid JSON string"}]
      end
    end)
  end

  def exjson_validator_errors_to_changeset_errors(field, errors) do
    Enum.map(errors, fn {error, path} ->
      {field, {"#{path}: #{error}", []}}
    end)
  end
end
