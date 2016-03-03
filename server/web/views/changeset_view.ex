defmodule Eden.ChangesetView do
  use Eden.Web, :view

  def render("error.json", %{changeset: changeset}) do
    Logger.debug "Rendering errors"

    errors = Enum.map(changeset.errors, fn {_field, detail} ->
      %{
        title: "Invalid Attribute",
        detail: render_detail(detail)
        }
    end)

    Logger.debug "Errors: #{inspect errors}"

    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: errors}
  end

  def render_detail({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_detail(message) do
    message
  end
end
