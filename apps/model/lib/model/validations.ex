defmodule Model.Validations do
  import Ecto.Changeset

  def validate_map(changeset, field) do
    validate_change(changeset, field, fn _, data ->
      if is_map(data) do
        []
      else
        [{field, "must be a map"}]
      end
    end)
  end
end
