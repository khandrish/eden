defmodule Exmud.Engine.Worker.SystemWorker do
  @moduledoc false

  alias Exmud.Engine.Repo
  alias Exmud.Engine.System
  import Ecto.Query
  import Exmud.Engine.Constants
  import Exmud.Common.Utils
  require Logger
  use GenServer

  defmodule State do
    @moduledoc false
    defstruct callback_module: nil,
              state: nil,
              timer_ref: nil
  end

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "A message passed through to a callback module."
  @type message :: term

  @typedoc "A reply passed through to the caller."
  @type reply :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "A response from the SystemWorker or the callback module."
  @type response :: term

  @typedoc "The reason the System is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @typedoc "A child spec for starting a process under a Supervisor."
  @type child_spec :: term

  @typedoc "The callback_module that is the implementation of the System logic."
  @type callback_module :: atom

  @system_registry system_registry()

  #
  # Worker callback used by the supervisor when starting a new System worker.
  #

  @spec child_spec(args :: term) :: child_spec
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args},
      restart: :transient,
      shutdown: 1000,
      type: :worker
    }
  end

  @spec start_link(callback_module, args) :: :ok | {:error, :already_started}
  def start_link(callback_module, start_args) do
    # Systems and modules have a one-to-one relationship. Make the key the module name.
    registered_name = via(@system_registry, callback_module)
    start_args = {callback_module, start_args}

    case GenServer.start_link(__MODULE__, start_args, name: registered_name) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end

  #
  # Initialization of the GenServer and the system it is managing.
  #

  @spec init({callback_module, args}) :: {:ok, state} | {:stop, error}
  def init({callback_module, start_args}) do
    # Load the System from the database. A System must be explicitly initialized before a worker can be started
    with {:ok, state} <- load_state(callback_module) do
      start_system(state, start_args)
    else
      {:error, error} ->
        {:stop, error}
    end
  end

  @spec load_state(callback_module) :: {:ok, state} | {:error, :no_such_system}
  defp load_state(callback_module) do
    case Repo.one(system_query(callback_module)) do
      nil ->
        Logger.info("System `#{callback_module}` not found.")

        {:error, :no_such_system}

      system ->
        Logger.info("System `#{callback_module}` loaded from database.")

        {:ok,
         %State{
           callback_module: callback_module,
           state: system.state
         }}
    end
  end

  @spec start_system(state, args) :: {:ok, state} | {:stop, error}
  defp start_system(state, start_args) do
    start_result = apply(state.callback_module, :start, [start_args, state.state])

    case start_result do
      {:ok, new_state, send_after} ->
        Logger.info("System `#{state.callback_module}` successfully started.")

        persist_if_changed(
          state.callback_module,
          state.state,
          new_state
        )

        # Trigger run after interval
        ref = Process.send_after(self(), :run, send_after)

        {:ok, %{state | state: new_state, timer_ref: ref}}

      {:error, error, new_state} ->
        Logger.error(
          "Encountered error `#{error}` while starting System `#{state.callback_module}`."
        )

        persist_if_changed(
          state.callback_module,
          state.state,
          new_state
        )

        {:stop, error}
    end
  end

  @doc false
  @spec handle_call(:run, from :: term, state) :: {:reply, :ok, state}
  def handle_call(:run, _from, state) do
    if is_reference(state.timer_ref) do
      Process.cancel_timer(state.timer_ref)
    end

    ref = Process.send_after(self(), :run, 0)

    {:reply, :ok, %{state | timer_ref: ref}}
  end

  @doc false
  @spec handle_call({:message, message}, from :: term, state) ::
          {:reply, {:ok, response}, state} | {:reply, {:error, error}, state}
  def handle_call({:message, message}, _from, state) do
    {tag, response, new_state} =
      apply(state.callback_module, :handle_message, [
        message,
        state.state
      ])

    persist_if_changed(
      state.callback_module,
      state.state,
      new_state
    )

    {:reply, {tag, response}, %{state | state: new_state}}
  end

  @doc false
  @spec handle_call(:state, from :: term, state) :: {:reply, {:ok, response}, state}
  def handle_call(:state, _from, state) do
    {:reply, {:ok, state.state}, state}
  end

  @doc false
  @spec handle_call(:running, from :: term, state) :: {:reply, true, state}
  def handle_call(:running, _from, state) do
    {:reply, true, state}
  end

  @doc false
  @spec handle_call({:stop, args}, from :: term, state) ::
          {:reply, :ok, state} | {:reply, {:error, error}, state}
  def handle_call({:stop, args}, _from, state) do
    if is_reference(state.timer_ref) do
      Process.cancel_timer(state.timer_ref)
    end

    stop_result = apply(state.callback_module, :stop, [args, state.state])

    {reply, new_state} =
      case stop_result do
        {:ok, new_state} ->
          Logger.info("System `#{state.callback_module}` successfully stopped.")

          {:ok, new_state}

        {:error, error, new_state} ->
          Logger.error(
            "Error `#{error}` encountered when stopping System #{state.callback_module}."
          )

          {{:error, error}, new_state}
      end

    persist_if_changed(
      state.callback_module,
      state.state,
      new_state
    )

    {:stop, :normal, reply, %{state | state: new_state}}
  end

  @doc false
  @spec handle_cast({:message, message}, state) :: {:noreply, state}
  def handle_cast({:message, message}, state) do
    {_type, _response, new_state} =
      apply(state.callback_module, :handle_message, [
        message,
        state.state
      ])

    persist_if_changed(state.callback_module, state.state, new_state)

    {:noreply, %{state | state: new_state}}
  end

  @doc false
  @spec handle_info(:run, state) :: {:noreply, state} | {:stop, :normal, state}
  def handle_info(:run, state) do
    state = %{state | timer_ref: nil}

    run(state)
  end

  @spec run(state) :: {:noreply, state} | {:stop, :normal, state}
  defp run(state) do
    run_result = apply(state.callback_module, :run, [state.state])

    {result, new_state} =
      case run_result do
        {:ok, new_state} ->
          Logger.info("System `#{state.callback_module}` successfully ran.")

          {{:noreply, %{state | state: new_state}}, new_state}

        {:ok, new_state, interval} ->
          Logger.info(
            "System `#{state.callback_module}` successfully ran. Running again in #{interval} milliseconds."
          )

          ref = Process.send_after(self(), :run, interval)

          {{:noreply, %{state | state: new_state, timer_ref: ref}}, new_state}

        {:error, error, new_state} ->
          Logger.error(
            "Error `#{error}` encountered when running System `#{state.callback_module}`."
          )

          {{:noreply, %{state | state: new_state}}, new_state}

        {:error, error, new_state, interval} ->
          Logger.error(
            "Error `#{error}` encountered when running System `#{state.callback_module}`.  Running again in #{
              interval
            } milliseconds."
          )

          ref = Process.send_after(self(), :run, interval)

          {{:noreply, %{state | state: new_state, timer_ref: ref}}, new_state}

        {:stop, reason, new_state} ->
          Logger.info("System `#{state.callback_module}` stopping after run.")

          stop_result = apply(state.callback_module, :stop, [reason, new_state])

          system_state =
            case stop_result do
              {:ok, system_state} ->
                Logger.info("System `#{state.callback_module}` successfully stopped.")

                system_state

              {:error, error, system_state} ->
                Logger.error(
                  "Error `#{error}` encountered when stopping System `#{state.callback_module}`."
                )

                system_state
            end

          {{:stop, :normal, %{state | state: system_state}}, system_state}
      end

    persist_if_changed(
      state.callback_module,
      state.state,
      new_state
    )

    result
  end

  #
  # Private Functions
  #

  @spec persist_if_changed(callback_module, state, state) :: term
  defp persist_if_changed(callback_module, old_state, new_state) do
    if new_state != old_state do
      :ok = System.update(callback_module, new_state)
    end
  end

  @spec system_query(callback_module) :: term
  defp system_query(callback_module) do
    from(
      system in Exmud.Engine.Schema.System,
      where: system.callback_module == ^callback_module
    )
  end
end
