defmodule ExmudWeb.TemplateEditLive do
  use Phoenix.LiveView

  alias Exmud.Engine

  def mount(%{template_id: id}, socket) do
    template_callback_set =
      Engine.list_template_callbacks(id)
      |> Enum.reduce(MapSet.new(), fn sc, ms -> MapSet.put(ms, sc.mud_callback.id) end)

    template = Engine.get_template!(id)

    callbacks =
      Engine.list_mud_callbacks(template.mud.id)
      |> Enum.map(fn cb ->
        %{callback: cb, present: MapSet.member?(template_callback_set, cb.id)}
      end)

    {:ok,
     assign(socket,
       callbacks: callbacks,
       template_id: id
     )}
  end

  def render(assigns) do
    Phoenix.View.render(
      ExmudWeb.TemplateCallbackView,
      "add_or_remove.html",
      assigns
    )
  end

  def handle_event("add", mud_callback_id, socket) do
    template_id = String.to_integer(socket.assigns.template_id)
    mud_callback_id = String.to_integer(mud_callback_id)

    mud_callback = Engine.get_mud_callback!(mud_callback_id)

    Engine.create_template_callback!(%{
      template_id: template_id,
      callback_id: mud_callback.callback.id,
      default_config: mud_callback.default_config
    })

    callbacks =
      Enum.map(socket.assigns.callbacks, fn cb ->
        if cb.callback.id == mud_callback_id do
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

  def handle_event("remove", mud_callback_id, socket) do
    mud_callback_id = String.to_integer(mud_callback_id)
    :ok = Engine.delete_template_callback!(mud_callback_id, socket.assigns.template_id)

    callbacks =
      Enum.map(socket.assigns.callbacks, fn cb ->
        if cb.mud_callback.id == mud_callback_id do
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
end
