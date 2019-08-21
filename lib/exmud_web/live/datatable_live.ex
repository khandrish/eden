defmodule ExmudWeb.DatatableLive do
  @moduledoc """
  Greatly reduces barrier of entry for the creation and management of Phoenix LiveView powered datatables.

  Only the minimal styling required for a working datatable is provided, leaving everything else up to the user via
  configuration or custom css.
  """
  use Phoenix.LiveView

  defmodule State do
    @enforce_keys [:callback_module, :columns]
    defstruct args: nil,
              # Module which implements Provider behaviour
              callback_module: nil,
              # Maps the keys in each row to the provided header as well as provides ordering
              columns: [],
              # If no column key has been provided as a 'group by' column, then no groups are created
              group_by: nil
  end

  defmodule Column do
    @enforce_keys [:header, :path]
    defstruct header: nil, path: []
  end

  def mount(session = %{columns: columns, module: callback_module, group_by: group_by}, socket) do
    state = %State{
      args: session[:args],
      callback_module: callback_module,
      columns: columns,
      group_by: group_by
    }

    {:ok, assign(socket, :state, state)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    state = assigns.state

    rows = state.callback_module.load(state)

    # sort rows by value of the provided group path
    # group the ones with the same values together under the same "heading" which is that value
    grouped_rows =
      case rows do
        [] ->
          nil

        _rows ->
          create_groups(rows, state)
      end

    assigns =
      assigns
      |> Map.put(:rows, rows)
      |> Map.put(:grouped_rows, grouped_rows)

    Phoenix.View.render(
      ExmudWeb.DatatableView,
      "datatable.html",
      assigns
    )
  end

  defp create_groups(_rows, _state = %{group_by: nil}) do
    nil
  end

  defp create_groups(rows, state) do
    rows
    |> Enum.sort(
      &(get_in(
          &1,
          for p <- state.group_by do
            Access.key!(p)
          end
        ) >=
          get_in(
            &2,
            for p <- state.group_by do
              Access.key!(p)
            end
          ))
    )
    |> Enum.chunk_by(
      &get_in(
        &1,
        for p <- state.group_by do
          Access.key!(p)
        end
      )
    )
    |> Enum.reduce(%{}, fn chunk = [row | _], map ->
      Map.put(
        map,
        get_in(
          row,
          for p <- state.group_by do
            Access.key!(p)
          end
        ),
        chunk
      )
    end)
  end
end
