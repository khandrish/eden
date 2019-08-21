defmodule ExmudWeb.TemplateEditLive do
  use Phoenix.LiveView

  alias Exmud.Engine

  def mount(%{template_id: id}, socket) do
    template_callback_set =
      Engine.list_template_callbacks(id)
      |> Enum.reduce(MapSet.new(), fn sc, ms -> MapSet.put(ms, sc.simulation_callback.id) end)

    template = Engine.get_template!(id)

    callbacks =
      Engine.list_simulation_callbacks(template.simulation.id)
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

  def handle_event("add", simulation_callback_id, socket) do
    template_id = String.to_integer(socket.assigns.template_id)
    simulation_callback_id = String.to_integer(simulation_callback_id)

    simulation_callback = Engine.get_simulation_callback!(simulation_callback_id)

    Engine.create_template_callback!(%{
      template_id: template_id,
      simulation_callback_id: simulation_callback_id,
      default_config: simulation_callback.default_config
    })

    callbacks =
      Enum.map(socket.assigns.callbacks, fn cb ->
        if cb.callback.id == simulation_callback_id do
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

  def handle_event("remove", simulation_callback_id, socket) do
    simulation_callback_id = String.to_integer(simulation_callback_id)
    :ok = Engine.delete_template_callback!(simulation_callback_id, socket.assigns.template_id)

    callbacks =
      Enum.map(socket.assigns.callbacks, fn cb ->
        if cb.simulation_callback.id == simulation_callback_id do
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
