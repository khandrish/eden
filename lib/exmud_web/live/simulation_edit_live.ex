defmodule ExmudWeb.SimulationEditLive do
  use Phoenix.LiveView

  alias Exmud.Engine

  def mount(%{simulation_id: id}, socket) do
    simulation_callback_set =
      Engine.list_simulation_callbacks(id)
      |> Enum.reduce(MapSet.new(), fn sc, ms -> MapSet.put(ms, sc.callback_id) end)

    callbacks =
      Engine.list_callbacks()
      |> Enum.map(fn cb ->
        %{callback: cb, present: MapSet.member?(simulation_callback_set, cb.id)}
      end)

    {:ok,
     assign(socket,
       callbacks: callbacks,
       simulation_id: id
     )}
  end

  def render(assigns) do
    Phoenix.View.render(
      ExmudWeb.SimulationCallbackView,
      "add_or_remove.html",
      assigns
    )
  end

  def handle_event("add", callback_id, socket) do
    simulation_id = String.to_integer(socket.assigns.simulation_id)
    callback_id = String.to_integer(callback_id)

    callback = Engine.get_callback!(callback_id)

    Engine.create_simulation_callback!(%{
      simulation_id: simulation_id,
      callback_id: callback_id,
      default_config: callback.default_config
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
    :ok = Engine.delete_simulation_callback!(callback_id, socket.assigns.simulation_id)

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
end
