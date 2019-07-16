defmodule Exmud.Engine.Worker.ScriptWorker do
  @moduledoc false

  alias Exmud.Engine.Repo
  alias Exmud.Engine.Script
  import Ecto.Query
  import Exmud.Engine.Constants
  import Exmud.Common.Utils
  require Logger
  use GenServer

  defmodule State do
    @moduledoc false
    defstruct callback_module: nil,
              state: nil,
              object_id: nil,
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

  @typedoc "A response from the ScriptWorker or the callback module."
  @type response :: term

  @typedoc "The reason the Script is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @typedoc "Id of the Object the Script is attached to."
  @type object_id :: integer

  @typedoc "A child spec for starting a process under a Supervisor."
  @type child_spec :: term

  @typedoc "a :via tuple allowing for Systems and Scripts to be registered seperately."
  @type registered_name :: term

  @typedoc "The callback_module that is the implementation of the Script logic."
  @type callback_module :: atom

  @script_registry script_registry()

  #
  # Worker callback used by the supervisor when starting a new Script Runner.
  #

  @doc false
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

  @doc false
  @spec start_link(
          object_id,
          callback_module,
          args
        ) :: :ok | {:error, :already_started}
  def start_link(object_id, callback_module, start_args) do
    registered_name = via(@script_registry, {object_id, callback_module})
    start_args = {object_id, callback_module, start_args}

    case GenServer.start_link(__MODULE__, start_args, name: registered_name) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end

  #
  # Initialization of the GenServer and the script it is managing.
  #

  @doc false
  @spec init({object_id, callback_module, args}) :: {:ok, state} | {:stop, error}
  def init({object_id, callback_module, start_args}) do
    # Load the Script from the database.
    with {:ok, state} <- load_state(object_id, callback_module) do
      start_script(state, start_args)
    else
      {:error, error} -> {:stop, error}
    end
  end

  @spec load_state(object_id, callback_module) :: {:ok, state} | {:error, :no_such_script}
  defp load_state(object_id, callback_module) do
    case Repo.one(script_query(object_id, callback_module)) do
      nil ->
        Logger.info(
          "Script `#{callback_module}` not found in the database for Object `#{object_id}`."
        )

        {:error, :no_such_script}

      script ->
        Logger.info("Script `#{callback_module}` loaded from database for Object `#{object_id}`.")

        {:ok,
         %State{
           object_id: script.object_id,
           callback_module: callback_module,
           state: script.state
         }}
    end
  end

  @spec start_script(state, args) :: {:ok, state} | {:stop, error}
  defp start_script(state, start_args) do
    start_result =
      apply(state.callback_module, :start, [state.object_id, start_args, state.state])

    case start_result do
      {:ok, new_state, send_after} ->
        Logger.info(
          "Script `#{state.callback_module}` successfully started for Object `#{state.object_id}`."
        )

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        # Trigger run after interval
        ref = Process.send_after(self(), :run, send_after)

        {:ok, %{state | state: new_state, timer_ref: ref}}

      {:error, error, new_state} ->
        Logger.error(
          "Encountered error `#{error}` while starting Script `#{state.callback_module}` for Object `#{
            state.object_id
          }`."
        )

        persist_if_changed(
          state.object_id,
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
    message_result =
      apply(state.callback_module, :handle_message, [
        state.object_id,
        message,
        state.state
      ])

    case message_result do
      {:ok, response, new_state} ->
        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:reply, {:ok, response}, %{state | state: new_state}}

      {:error, error, new_state} ->
        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:reply, {:error, error}, %{state | state: new_state}}
    end
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

    stop_result = apply(state.callback_module, :stop, [state.object_id, args, state.state])

    Process.send_after(self(), :stop, 0)

    case stop_result do
      {:ok, new_state} ->
        Logger.info(
          "Script `#{state.callback_module}` successfully stopped for Object `#{state.object_id}`."
        )

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:reply, :ok, %{state | state: new_state}}

      {:error, error, new_state} ->
        Logger.error(
          "Error `#{error}` encountered when stopping Script `#{state.callback_module}` for Object `#{
            state.object_id
          }`."
        )

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:reply, {:error, error}, %{state | state: new_state}}
    end
  end

  @doc false
  @spec handle_cast({:message, message}, state) :: {:noreply, state}
  def handle_cast({:message, message}, state) do
    {_type, _response, new_state} =
      apply(state.callback_module, :handle_message, [
        state.object_id,
        message,
        state.state
      ])

    persist_if_changed(
      state.object_id,
      state.callback_module,
      state.state,
      new_state
    )

    {:noreply, %{state | state: new_state}}
  end

  @doc false
  @spec handle_info(:run, state) :: {:noreply, state} | {:stop, :normal, state}
  def handle_info(:run, state) do
    state = %{state | timer_ref: nil}

    run(state)
  end

  @doc false
  @spec handle_info(:stop, state) :: {:stop, :normal, state}
  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  @spec run(state) :: {:noreply, state} | {:stop, :normal, state}
  defp run(state) do
    run_result = apply(state.callback_module, :run, [state.object_id, state.state])

    case run_result do
      {:ok, new_state} ->
        Logger.info("Script `#{state.callback_module}` successfully ran.")

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:noreply, %{state | state: new_state}}

      {:ok, new_state, interval} ->
        Logger.info(
          "Script `#{state.callback_module}` successfully ran. Running again in #{interval} milliseconds."
        )

        ref = Process.send_after(self(), :run, interval)

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:noreply, %{state | state: new_state, timer_ref: ref}}

      {:error, error, new_state} ->
        Logger.error(
          "Error `#{error}` encountered when running Script `#{state.callback_module}`."
        )

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:noreply, %{state | state: new_state}}

      {:error, error, new_state, interval} ->
        Logger.error(
          "Error `#{error}` encountered when running Script `#{state.callback_module}`.  Running again in #{
            interval
          } milliseconds."
        )

        ref = Process.send_after(self(), :run, interval)

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          new_state
        )

        {:noreply, %{state | state: new_state, timer_ref: ref}}

      {:stop, reason, new_state} ->
        Logger.info("Script `#{state.callback_module}` stopping after run.")

        stop_result = apply(state.callback_module, :stop, [state.object_id, reason, new_state])

        script_state =
          case stop_result do
            {:ok, script_state} ->
              Logger.info("Script `#{state.callback_module}` successfully stopped.")
              script_state

            {:error, error, script_state} ->
              Logger.error(
                "Error `#{error}` encountered when stopping Script `#{state.callback_module}`."
              )

              script_state
          end

        persist_if_changed(
          state.object_id,
          state.callback_module,
          state.state,
          script_state
        )

        {:stop, :normal, %{state | state: script_state}}
    end
  end

  #
  # Private Functions
  #

  @spec persist_if_changed(object_id, callback_module, state, state) :: term
  defp persist_if_changed(object_id, callback_module, old_state, new_state) do
    if new_state != old_state do
      :ok = Script.update(object_id, callback_module, new_state)
    end
  end

  @spec script_query(object_id, callback_module) :: term
  defp script_query(object_id, callback_module) do
    from(
      script in Exmud.Engine.Schema.Script,
      where: script.object_id == ^object_id and script.callback_module == ^callback_module
    )
  end
end
