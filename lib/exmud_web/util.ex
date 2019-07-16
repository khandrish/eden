defmodule ExmudWeb.Util do
  def get_input_field_class(changeset, field) do
    cond do
      Map.has_key?(changeset.changes, field) and
          not Exmud.Util.changeset_has_error?(changeset, field) ->
        "success"

      Exmud.Util.changeset_has_error?(changeset, field) ->
        "error"

      true ->
        ""
    end
  end
end
