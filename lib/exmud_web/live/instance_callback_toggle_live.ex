defmodule ExmudWeb.EngineCallbackToggleLive do
  use Phoenix.LiveView

  alias Exmud.Builder

  def mount(%{callback_id: callback_id, mud_id: mud_id, present: present}, socket) do
    {:ok,
     assign(socket,
       callback_id: callback_id,
       mud_id: mud_id,
       present: present
     )}
  end

  def render(assigns) do
    Phoenix.View.render(
      ExmudWeb.EngineView,
      "add_or_remove_button.html",
      assigns
    )
  end

  def handle_event("add", _, socket) do
    mud_id = socket.assigns.mud_id
    callback_id = socket.assigns.callback_id

    callback = Builder.get_callback!(callback_id)

    Builder.create_mud_callback!(%{
      mud_id: mud_id,
      callback_id: callback_id,
      config: callback.config
    })

    {:noreply,
     assign(socket,
       present: true
     )}
  end

  def handle_event("remove", _, socket) do
    :ok = Builder.delete_mud_callback!(socket.assigns.callback_id, socket.assigns.mud_id)

    {:noreply,
     assign(socket,
       present: false
     )}
  end
end
