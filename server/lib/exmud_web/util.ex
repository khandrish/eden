defmodule ExmudWeb.Util do

  @doc """
  Determine the CSS input class for a given field and changeset.
  """
  def get_input_field_class(changeset, field) do
    cond do
      Map.has_key?(changeset.changes, field) and
          not Exmud.Util.changeset_has_error?(changeset, field) ->
        "valid"

      Exmud.Util.changeset_has_error?(changeset, field) ->
        "invalid"

      true ->
        ""
    end
  end

  @doc """
  Uses the last url in NavigationHistory as the target for a redirect.
  """
  def redirect_back(conn, opts \\ []) do
    Phoenix.Controller.redirect(conn, to: NavigationHistory.last_path(conn, opts))
  end
end
