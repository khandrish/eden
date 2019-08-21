defmodule ExmudWeb.DatatableLive do
  @moduledoc """
  Greatly reduces barrier of entry for the creation and management of Phoenix LiveView powered datatables.

  Only the minimal styling required for a working datatable is provided, leaving everything else up to the user via
  configuration or custom css.
  """
  use Phoenix.LiveView

  defmodule State do
    @enforce_keys [:callback_module, :name]
    defstruct args: nil,
              callback_module: nil,
              # Column order, initially populated via the
              columns: [],
              current_page: 0,
              name: nil,
              rows: [],
              page_size: 10,
              search: "",
              sort: []
  end

  # ?<tablename>:current_page=1,<tablename>:page_size=10,<tablename>:search=any,<tablename>:sort=sadwas,<tablename>:column_order=[1,3,2,4,5,9,7,8]

  def mount(session = %{module: callback_module, name: name}, socket) do
    state = %State{args: session[:args], callback_module: callback_module, name: name}

    {:ok, assign(socket, :state, state)}
  end

  def handle_params(_params, _uri, socket) do
    state = socket.assigns.state

    case state.callback_module.load(state) do
      {:ok, rows} ->
        {:noreply,
         assign(socket, %{
           state: %{state | rows: rows}
         })}

      _error ->
        {:noreply, state}
    end
  end

  def render(assigns) do
    Phoenix.View.render(
      ExmudWeb.DatatableView,
      "datatable.html",
      assigns
    )
  end

  # def handle_event("validate", _form = %{"profile" => params}, socket) do
  #   changeset = Exmud.Account.Profile.new(params) |> Map.put(:action, :insert)

  #   {:noreply,
  #    assign(socket,
  #      changeset: changeset,
  #      has_nickname_error?: Exmud.Util.changeset_has_error?(changeset, :nickname),
  #      has_email_error?: Exmud.Util.changeset_has_error?(changeset, :email)
  #    )}
  # end
end
