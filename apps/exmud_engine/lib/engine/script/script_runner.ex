defmodule Exmud.Engine.ScriptRunner do
  @moduledoc false

  alias Exmud.Engine.Repo
  alias Exmud.Engine.Script
  import Ecto.Changeset
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger
  use GenServer

  @script_registry script_registry()

  defmodule State do
    defstruct deserialized_state: nil, timer_ref: nil, callback_module: nil, script_name: nil, object_id: nil
  end


  #
  # Worker callback used by the supervisor when starting a new Script runner.
  #


  @doc false
  def start_link(object_id, script_name, args) do
    case GenServer.start_link(__MODULE__, {object_id, script_name, args}, name: via(@script_registry, {object_id, script_name})) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end


  #
  # Initialization of the GenServer and the Script it is managing.
  #


  @doc false
  def init({object_id, script_name, args}) do
    wrap_callback_in_transaction(fn ->
      # Either load the Script from the database, or create a new State struct. This struct contains the state of the
      # Script as understood by the callback, as well as information used by the Engine to execute the Script properly.
      with {:ok, callback_module} <- Script.lookup(script_name),
           {:ok, state} <- load_script(object_id, script_name, callback_module, args)
      do
        start_script(state, args)
      else
        {:error, error} -> {:stop, error}
      end
    end)
  end

  defp load_script(object_id, script_name, callback_module, args) do
    case Repo.one(script_query(object_id, script_name)) do
      nil ->
        Logger.info("Script `#{script_name}` not found in the database on Object `#{object_id}`.")

        initialization_result = apply(callback_module, :initialize, [object_id, args])

        case initialization_result do
          {:ok, new_state} ->
            Logger.info("Script `#{script_name}` successfully initialized on Object `#{object_id}`.")

            Exmud.Engine.Schema.Script.new(%{object_id: object_id, name: script_name, state: pack_term(new_state)})
            |> Repo.insert!()

            {:ok, %State{object_id: object_id,
                         script_name: script_name,
                         deserialized_state: new_state,
                         callback_module: callback_module}}
          {_, error} = result ->
            Logger.error("Encountered error `#{error}` while initializing Script `#{script_name}` on Object `#{object_id}`.")

            result
        end
      script ->
        Logger.info("Script `#{script_name}` loaded from database.")

        {:ok, %State{object_id: script.object_id,
                     script_name: script.name,
                     deserialized_state: unpack_term(script.state),
                     callback_module: callback_module}}
    end
  end

  defp start_script(state, start_args) do
    start_result = apply(state.callback_module,
                         :start,
                         [state.object_id, start_args, state.deserialized_state])

    case start_result do
      {:ok, new_state, send_after} ->
        Logger.info("Script `#{state.script_name}` successfully started on Object `#{state.object_id}`.")

        persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

        # Trigger run after interval
        ref = Process.send_after(self(), :run, send_after)

        {:ok, %{state | deserialized_state: new_state,
                        timer_ref: ref}}
      {:error, error, new_state} ->
        Logger.error("Encountered error `#{error}` while starting Script `#{state.script_name}` on Object `#{state.object_id}`.")

        persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

        {:stop, error}
    end
  end

  @doc false
  def handle_call(:run, from, state) do
    if state.timer_ref != nil do
      Process.cancel_timer(state.timer_ref)
    end

    ref = Process.send_after(self(), :run, 0)

    {:reply, :ok, %{state | timer_ref: ref}}
  end

  @doc false
  def handle_call({:message, message}, _from, state) do
    wrap_callback_in_transaction(fn ->
      message_result = apply(state.callback_module,
                             :handle_message,
                             [state.object_id, message, state.deserialized_state])

      case message_result do
        {:ok, response, new_state} ->
          persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)
          {:reply, {:ok, response}, %{state | deserialized_state: new_state}}
        {:error, error, new_state} ->
          persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)
          {:reply, {:error, error}, %{state | deserialized_state: new_state}}
      end
    end)
  end

  @doc false
  def handle_call(:state, _from, state) do
    {:reply, {:ok, state.deserialized_state}, state}
  end

  @doc false
  def handle_call({:stop, reason}, _from, state) do
    if state.timer_ref != nil do
      Process.cancel_timer(state.timer_ref)
    end

    wrap_callback_in_transaction(fn ->
      stop_result = apply(state.callback_module,
                          :stop,
                          [state.object_id, reason, state.deserialized_state])

      case stop_result do
        {:ok, new_state} ->
          Logger.info("Script `#{state.script_name}` successfully stopped on Object `#{state.object_id}`.")

          persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

          {:stop, :normal, :ok, %{state | deserialized_state: new_state}}
        {:error, error, new_state} ->
          Logger.error("Error `#{error}` encountered when stopping Script `#{state.script_name}` on Object `#{state.object_id}`.")

          persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

          {:stop, :normal, {:error, error}, %{state | deserialized_state: new_state}}
      end
    end)
  end

  @doc false
  def handle_cast({:message, message}, state) do
    wrap_callback_in_transaction(fn ->
      {_type, _response, new_state} = apply(state.callback_module,
                                            :handle_message,
                                            [state.object_id, message, state.deserialized_state])

      persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

      {:noreply, %{state | deserialized_state: new_state}}
    end)
  end

  @doc false
  def handle_info(:run, state) do
    state = %{state | timer_ref: nil}

    wrap_callback_in_transaction(fn ->
      run(state)
    end)
  end

  defp run(state) do
    run_result = apply(state.callback_module,
                       :run,
                       [state.object_id, state.deserialized_state])

    case run_result do
      {:ok, new_state} ->
        Logger.info("Script `#{state.script_name}` on Object `#{state.object_id}` successfully ran.")

        persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

        {:noreply, %{state | deserialized_state: new_state}}
      {:ok, new_state, interval} ->
        Logger.info("Script `#{state.script_name}` on Object `#{state.object_id}` successfully ran. Running again in #{interval} milliseconds.")

        ref = Process.send_after(self(), :run, interval)
        persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

        {:noreply, %{state | deserialized_state: new_state, timer_ref: ref}}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when running Script `#{state.script_name}` on Object `#{state.object_id}.")

        persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

        {:noreply, %{state | deserialized_state: new_state}}
      {:error, error, new_state, interval} ->
        Logger.error("Error `#{error}` encountered when running Script `#{state.script_name}` on Object `#{state.object_id}.  Running again in #{interval} milliseconds.")

        ref = Process.send_after(self(), :run, interval)
        persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

        {:noreply, %{state | deserialized_state: new_state, timer_ref: ref}}
      {:stop, reason, new_state} ->
        Logger.info("Script `#{state.script_name}` on Object `#{state.object_id} stopping after run.")

        stop_result = apply(state.callback_module,
                            :stop,
                            [state.object_id, reason, new_state])

        script_state =
          case stop_result do
            {:ok, script_state} ->
              Logger.info("Script `#{state.script_name}` on Object `#{state.object_id} successfully stopped.")
              script_state
            {:error, error, script_state} ->
              Logger.error("Error `#{error}` encountered when stopping Script `#{state.script_name}` on Object `#{state.object_id}.")
              script_state
          end

        persist_if_changed(state.object_id, state.script_name, state.deserialized_state, new_state)

        {:stop, :normal, %{state | deserialized_state: new_state}}
    end
  end


  #
  # Private Functions
  #


  defp persist_if_changed(object_id, script_name, old_state, new_state) do
    if new_state != old_state do
      :ok = Script.update(object_id, script_name, new_state)
    end
  end

  defp script_query(object_id, name) do
    from script in Exmud.Engine.Schema.Script,
      where: script.name == ^name and script.object_id == ^object_id
  end
end