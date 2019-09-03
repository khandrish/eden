defmodule ExmudWeb.EngineEditLive do
  use Phoenix.LiveView

  alias Exmud.Builder

  def mount(%{id: id}, socket) do
    mud = Builder.get_mud!(id)
    changeset = Builder.change_mud(mud)

    {:ok,
     assign(socket,
       changeset: changeset,
       has_name_error?: false
     )}
  end

  def render(assigns) do
    Phoenix.View.render(
      ExmudWeb.EngineView,
      "edit_form.html",
      assigns
    )
  end

  def handle_event("add", callback_id, socket) do
    mud_id = String.to_integer(socket.assigns.mud_id)
    callback_id = String.to_integer(callback_id)

    callback = Builder.get_callback!(callback_id)

    Builder.create_mud_callback!(%{
      mud_id: mud_id,
      callback_id: callback_id,
      config: callback.config
    })

    callbacks =
      Enum.map(socket.assigns.callbacks, fn cb ->
        if cb.callback.id == callback_id do
          %{cb | present: true}
        else
          cb
        end
      end)

    {:noreply,
     assign(socket,
       callbacks: callbacks
     )}
  end

  def handle_event("remove", callback_id, socket) do
    callback_id = String.to_integer(callback_id)
    :ok = Builder.delete_mud_callback!(callback_id, socket.assigns.mud_id)

    callbacks =
      Enum.map(socket.assigns.callbacks, fn cb ->
        if cb.callback.id == callback_id do
          %{cb | present: false}
        else
          cb
        end
      end)

    {:noreply,
     assign(socket,
       callbacks: callbacks
     )}
  end

  def handle_event("validate", _form = %{"mud" => params}, socket) do
    changeset = Exmud.Engine.Mud.new(params) |> Map.put(:action, :insert)

    {:noreply,
     assign(socket,
       changeset: changeset,
       has_name_error?: Exmud.Util.changeset_has_error?(changeset, :name)
     )}
  end
end
