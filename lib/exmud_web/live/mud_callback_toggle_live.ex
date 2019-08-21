defmodule ExmudWeb.MudCallbackToggleLive do
  use Phoenix.LiveView

  alias Exmud.Engine

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
      ExmudWeb.MudView,
      "add_or_remove_button.html",
      assigns
    )
  end

  def handle_event("add", _, socket) do
    mud_id = socket.assigns.mud_id
    callback_id = socket.assigns.callback_id

    callback = Engine.get_callback!(callback_id)

    Engine.create_mud_callback!(%{
      mud_id: mud_id,
      callback_id: callback_id,
      default_config: callback.default_config
    })

    {:noreply,
     assign(socket,
       present: true
     )}
  end

  def handle_event("remove", _, socket) do
    :ok = Engine.delete_mud_callback!(socket.assigns.callback_id, socket.assigns.mud_id)

    {:noreply,
     assign(socket,
       present: false
     )}
  end
end
