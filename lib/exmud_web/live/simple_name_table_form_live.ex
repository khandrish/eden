defmodule ExmudWeb.SimpleNameTableFormLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(
      ExmudWeb.LiveComponentsView,
      "simple_name_table_form.html",
      assigns
    )
  end

  def mount(session = %{header: header, mud_id: mud_id}, socket) do
    changeset = session.callback_module.new() |> session.callback_module.changeset()
    names = Map.get(session, :names, [])

    {:ok,
     assign(socket,
       callback_module: session.callback_module,
       changeset: changeset,
       has_name_error?: false,
       header: header,
       mud_id: mud_id,
       names: names
     )}
  end

  def handle_event("validate", _form = %{"form" => params}, socket) do
    changeset =
      socket.assigns.callback_module.new()
      |> socket.assigns.callback_module.changeset(
        Map.put(params, "mud_id", socket.assigns.mud_id)
      )
      |> Map.put(:action, :insert)

    {:noreply,
     assign(socket,
       changeset: changeset,
       has_name_error?: Exmud.Util.changeset_has_error?(changeset, :name)
     )}
  end

  def handle_event("save", _form = %{"form" => params}, socket) do
    changeset =
      socket.assigns.callback_module.new()
      |> socket.assigns.callback_module.changeset(
        Map.put(params, "mud_id", socket.assigns.mud_id)
      )

    case Exmud.Repo.insert(changeset) do
      {:ok, thing} ->
        changeset =
          socket.assigns.callback_module.new() |> socket.assigns.callback_module.changeset()

        {:noreply,
         assign(socket,
           changeset: changeset,
           names: Enum.sort([thing.name | socket.assigns.names])
         )}

      {:error, changeset = %Ecto.Changeset{}} ->
        {:noreply,
         assign(socket,
           changeset: changeset,
           has_name_error?: Exmud.Util.changeset_has_error?(changeset, :name)
         )}
    end
  end

  def handle_event("delete", name, socket) do
    socket.assigns.callback_module.delete_by_name(name)

    {:noreply,
     assign(socket,
       names: Enum.filter(socket.assigns.names, &(&1 != name))
     )}
  end
end
