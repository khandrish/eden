defmodule Exmud.Engine.ScriptRunner do
  @moduledoc false

  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Script
  import Ecto.Changeset
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger
  use GenServer

  @script_registry script_registry()


  #
  # Worker callback used by the supervisor when starting a new Script runner.
  #


  @doc false
  def start_link(object_id, name, args) do
    case GenServer.start_link(__MODULE__, {object_id, name, args}, name: via(@script_registry, {object_id, name})) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end


  #
  # Initialization of the GenServer and the Script it is managing.
  #


  @doc false
  def init({object_id, name, args}) do
    # Either load the Script from the database, or create a new Script struct. This struct contains the state of the
    # Script as understood by the callback, as well as information used by the Engine to execute the Script properly.
    with {:ok, callback_module} <- Exmud.Engine.Script.lookup(name),
         {:ok, loaded_script} <- load_script(object_id, name, callback_module, args)
    do
      start_script(loaded_script, args)
    else
      {:error, error} -> {:stop, error}
    end
  end

  defp load_script(object_id, name, callback_module, args) do
    case Repo.one(script_query(object_id, name)) do
      nil ->
        Logger.info("Script `#{name}` not found in the database on Object `#{object_id}`.")

        initialization_result = apply(callback_module, :initialize, [object_id, args])

        case initialization_result do
          {:ok, new_state} ->
            Logger.info("Script `#{name}` successfully initialized on Object `#{object_id}`.")

            {:ok, Script.new(%{callback_module: callback_module, deserialized_state: new_state, object_id: object_id, name: name})}
          {_, error} = result ->
            Logger.error("Encountered error `#{error}` while initializing Script `#{name}` on Object `#{object_id}`.")

            result
        end
      script ->
        Logger.info("Script `#{name}` loaded from database.")

        deserialized_state = unpack_term(script.state)

        {:ok, Script.load(script, %{callback_module: callback_module, deserialized_state: deserialized_state})}
    end
  end

  defp start_script(script, start_args) do
    start_result = apply(get_field(script, :callback_module),
                         :start,
                         [get_field(script, :object_id), start_args, get_field(script, :deserialized_state)])

    case start_result do
      {:ok, state, send_after} ->
        Logger.info("Script `#{get_field(script, :name)}` successfully started on Object `#{get_field(script, :object_id)}`.")

        {:ok, script} = Repo.insert_or_update(change(script, state: pack_term(state)))
        script = change(script, deserialized_state: state)

        # Trigger run after interval
        Process.send_after(self(), :run, send_after)

        {:ok, script}
      {:error, error, new_state} ->
        Logger.error("Encountered error `#{error}` while starting Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)}`.")

        Repo.insert_or_update(change(script, state: pack_term(new_state)))

        {:stop, error}
    end
  end

  @doc false
  def handle_call(:run, from, script) do
    GenServer.reply(from, :ok)

    run(script)
  end

  @doc false
  def handle_call({:message, message}, _from, script) do
    message_result = apply(get_field(script, :callback_module),
                           :handle_message,
                           [get_field(script, :object_id), message, get_field(script, :deserialized_state)])

    case message_result do
      {:ok, response, new_state} ->
        {:reply, {:ok, response}, update_and_persist(script, new_state)}
      {:error, error, new_state} ->
        {:reply, {:error, error}, update_and_persist(script, new_state)}
    end
  end

  @doc false
  def handle_call(:state, _from, script) do
    {:reply, {:ok, get_field(script, :deserialized_state)}, script}
  end

  @doc false
  def handle_call({:stop, reason}, _from, script) do
    stop_result = apply(get_field(script, :callback_module),
                        :stop,
                        [get_field(script, :object_id), reason, get_field(script, :deserialized_state)])

    case stop_result do
      {:ok, new_state} ->
        Logger.info("Script `#{get_field(script, :name)}` successfully stopped on Object `#{get_field(script, :object_id)}`.")

        script = update_and_persist(script, new_state)

        {:stop, :normal, :ok, script}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when stopping Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)}`.")

        script = update_and_persist(script, new_state)

        {:stop, :normal, {:error, error}, script}
    end
  end

  @doc false
  def handle_cast({:message, message}, script) do
    {_type, _response, new_state} = apply(get_field(script, :callback_module),
                                          :handle_message,
                                          [get_field(script, :object_id), message, get_field(script, :deserialized_state)])

    {:noreply, update_and_persist(script, new_state)}
  end

  @doc false
  def handle_info(:run, script) do
    run(script)
  end

  defp run(script) do
    run_result = apply(get_field(script, :callback_module),
                       :run,
                       [get_field(script, :object_id), get_field(script, :deserialized_state)])

    case run_result do
      {:ok, new_state} ->
        Logger.info("Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)}` successfully ran.")

        {:noreply, update_and_persist(script, new_state)}
      {:ok, new_state, interval} ->
        Logger.info("Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)}` successfully ran. Running again in #{interval} milliseconds.")

        Process.send_after(self(), :run, interval)

        {:noreply, update_and_persist(script, new_state)}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when running Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)}.")

        {:noreply, update_and_persist(script, new_state)}
      {:error, error, new_state, interval} ->
        Logger.error("Error `#{error}` encountered when running Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)}.  Running again in #{interval} milliseconds.")

        Process.send_after(self(), :run, interval)

        {:noreply, update_and_persist(script, new_state)}
      {:stop, reason, new_state} ->
        Logger.info("Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)} stopping after run.")

        stop_result = apply(get_field(script, :callback_module),
                            :stop,
                            [get_field(script, :object_id), reason, new_state])

        script_state =
          case stop_result do
            {:ok, script_state} ->
              Logger.info("Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)} successfully stopped.")
              script_state
            {:error, error, script_state} ->
              Logger.error("Error `#{error}` encountered when stopping Script `#{get_field(script, :name)}` on Object `#{get_field(script, :object_id)}.")
              script_state
          end

        script = update_and_persist(script, script_state)

        {:stop, :normal, script}
    end
  end


  #
  # Private Functions
  #


  defp update_and_persist(script, new_script_state) do
    if new_script_state == get_field(script, :deserialized_state) do
      script
    else
      state = pack_term(new_script_state)

      {:ok, script} = Repo.update(change(script, state: state))
      change(script, deserialized_state: new_script_state)
    end
  end

  defp script_query(object_id, name) do
    from script in Script,
      where: script.name == ^name,
      where: script.object_id == ^object_id
  end
end