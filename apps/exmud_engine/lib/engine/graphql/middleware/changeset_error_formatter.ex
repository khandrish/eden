defmodule Exmud.Engine.Graphql.Middleware.ChangesetErrorFormatter do
  import Ecto.Changeset

  def call(%{errors: []} = res, _), do: res

  def call(%{errors: errors} = res, _), do: %{res | errors: format_changeset_error(errors)}

  def format_changeset_error(errors) when is_list(errors) do
    cond do
      Enum.all?(errors, &is_changeset/1) -> Enum.flat_map(errors, &format_changeset_error/1)
      Enum.all?(errors, &is_bitstring/1) -> errors
      Enum.all?(errors, &is_map/1) -> errors
      true -> Enum.flat_map(errors, &format_changeset_error/1)
    end
  end

  def format_changeset_error(%Ecto.Changeset{} = changeset), do: format_changeset(changeset)

  def format_changeset_error(error), do: error

  defp format_changeset(str) when is_bitstring(str), do: str

  defp format_changeset(changeset) do
    changeset
      |> interpolate_errors
      |> Map.to_list
      |> Enum.flat_map(fn {field, errors} -> field_errors_to_error(changeset, field, errors) end)
  end

  def field_errors_to_error(changeset, field, errors) do
    field_name = Atom.to_string(field)
    Enum.map(errors, fn error ->
      %{
        message: field_name <> " " <> error,
        value: error_field_value(changeset, field)
      }
    end)
  end

  defp interpolate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @spec error_field_value(changeset :: Ecto.Changeset.t, field :: atom) :: any
  defp error_field_value(changeset, field) do
    case Ecto.Changeset.fetch_field(changeset, field) do
      {_, value} -> value
      :error -> nil
    end
  end

  defp is_changeset(%Ecto.Changeset{} = _), do: true

  defp is_changeset(_), do: false
end