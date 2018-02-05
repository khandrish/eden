defmodule Exmud.Engine.ScriptRunner do
  @moduledoc false

  defmodule State do
    @moduledoc false
    defstruct running: false, script: nil
  end

  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Script
  import Ecto.Changeset
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger
  use GenServer


  #
  # Worker callback used by the supervisor when starting a new Script runner.
  #


  @doc false
  def start_link(key, args) do
    case GenServer.start_link(__MODULE__, {key, args}) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end


  #
  # Initialization of the GenServer and the Script it is managing.
  #


  @doc false
  def init({key, args}) do
    # Either load the Script from the database, or create a new Script struct. This struct contains the state of the
    # Script as understood by the callback, as well as information used by the Engine to execute the Script properly.
    with {:ok, callback_module} <- Exmud.Engine.Script.lookup(key),
         loaded_script <- load_script(key, callback_module),
         {:ok, initialized_script, initialized_args} <- initialize_script(loaded_script, args)
    do
      start_script(initialized_script, initialized_args)
    else
      {:error, error} -> {:stop, error}
    end
  end

  defp load_script(key, callback_module) do
    case Repo.one(from(script in Script, where: script.key == ^key)) do
      nil ->
        Logger.info("Script `#{key}` not found in the database.")

        change(%Script{}, callback_module: callback_module, key: key, state: nil)
      script ->
        Logger.info("Script `#{key}` loaded from database.")

        change(script, callback_module: callback_module, initialized: true, state: deserialize(script.state))
    end
  end

  defp initialize_script(script, args) do
    if get_field(script, :initialized) do
      Logger.info("Script `#{get_field(script, :key)}` already initialized.")

      {:ok, script, args}
    else
      initialization_result = apply(get_field(script, :callback_module), :initialize, [args])

      case initialization_result do
        {:ok, new_state} ->
          Logger.info("Script `#{get_field(script, :key)}` successfully initialized. Returning passed in args.")

          {:ok, change(script, state: new_state), args}
        {:ok, new_state, new_args} ->
          Logger.info("Script `#{get_field(script, :key)}` successfully initialized. Returning modified args.")

          {:ok, change(script, state: new_state), new_args}
        {_, error} = result ->
          Logger.error("Encountered error `#{error}` while initializing Script `#{get_field(script, :key)}`.")

          result
      end
    end
  end

  defp start_script(script, start_args) do
    start_result = apply(get_field(script, :callback_module),
                         :start,
                         [get_field(script, :state), start_args])

    if elem(start_result, 0) == :ok do
      Logger.info("Script `#{get_field(script, :key)}` successfully started.")

      # Update the running status...or not
      script =
        case start_result do
          {_, new_state} ->
            change(script, state: serialize(new_state))
          {_, new_state, _} ->
            change(script, running: true, state: serialize(new_state))
        end

      # Save modified state immediately
      {:ok, script} = Repo.insert_or_update(Script.cast(script))
      script = change(script, state: deserialize(script.state))

      # If an interval was returned, trigger run after said interval
      if get_field(script, :running), do: Process.send_after(self(), :auto_run, elem(start_result, 2))

      {:ok, script}
    else
      {_, error, new_state} = start_result

      Logger.error("Encountered error `#{error}` while starting Script `#{get_field(script, :key)}`.")

      Repo.insert_or_update(change(script, state: new_state))

      {:stop, error}
    end
  end

  @doc false
  def handle_call(:start_running, _from, script) do
    if get_field(script, :running) do
      {:reply, {:error, :already_running}, script}
    else
      Process.send_after(self(), :auto_run, 0)

      {:reply, {:ok, :running}, change(script, running: true)}
    end
  end

  @doc false
  def handle_call({:message, message}, _from, script) do
    message_result = apply(get_field(script, :callback_module),
                           :handle_message,
                           [message, get_field(script, :state)])

    case message_result do
      {:ok, response, new_state} ->
        {:reply, {:ok, response}, update_and_persist(script, new_state)}
      {:error, error, new_state} ->
        {:reply, {:error, error}, update_and_persist(script, new_state)}
    end
  end

  @doc false
  def handle_call(:state, _from, script) do
    {:reply, {:ok, get_field(script, :state)}, script}
  end

  @doc false
  def handle_call({:stop, args}, _from, script) do
    stop_result = apply(get_field(script, :callback_module),
                        :stop,
                        [args, get_field(script, :state)])

    case stop_result do
      {:ok, new_state} ->
        Logger.info("Script `#{get_field(script, :key)}` successfully stopped.")

        script = update_and_persist(script, new_state, false)

        {:stop, :normal, {:ok, :stopped}, script}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when stopping Script `#{get_field(script, :key)}`.")

        script = update_and_persist(script, new_state, false)

        {:stop, :normal, {:error, error}, script}
    end
  end

  @doc false
  def handle_cast({:message, message}, script) do
    {_type, _response, new_state} = apply(get_field(script, :callback_module),
                                          :handle_message,
                                          [message, get_field(script, :state)])

    {:noreply, update_and_persist(script, new_state)}
  end

  @doc false
  def handle_info(:auto_run, script) do
    run_result = apply(get_field(script, :callback_module),
                                 :run,
                                 [get_field(script, :state)])

    case run_result do
      {:ok, new_state} ->
        Logger.info("Script `#{get_field(script, :key)}` successfully ran.")

        {:noreply, update_and_persist(script, new_state, false)}
      {:ok, new_state, interval} ->
        Logger.info("Script `#{get_field(script, :key)}` successfully ran. Running again in #{interval} milliseconds.")

        Process.send_after(self(), :auto_run, interval)

        {:noreply, update_and_persist(script, new_state, true)}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when running Script `#{get_field(script, :key)}`.")

        {:noreply, update_and_persist(script, new_state, false)}
      {:error, error, new_state, interval} ->
        Logger.error("Error `#{error}` encountered when running Script `#{get_field(script, :key)}`.  Running again in #{interval} milliseconds.")

        Process.send_after(self(), :auto_run, interval)

        {:noreply, update_and_persist(script, new_state, true)}
      {:stop, reason, new_state} ->
        Logger.info("Script `#{get_field(script, :key)}` stopping after run.")


        stop_result = apply(get_field(script, :callback_module),
                            :stop,
                            [reason, new_state])

        script_state =
          case stop_result do
            {:ok, script_state} ->
              Logger.info("Script `#{get_field(script, :key)}` successfully stopped.")
              script_state
            {:error, error, script_state} ->
              Logger.error("Error `#{error}` encountered when stopping Script `#{get_field(script, :key)}`.")
              script_state
          end

        script = update_and_persist(script, script_state, false)

        {:stop, :normal, script}
    end
  end


  #
  # Private Functions
  #

  defp update_and_persist(script, new_script_state) do
    script = change(script, state: serialize(new_script_state))
    do_persist(script)
  end

  defp update_and_persist(script, new_script_state, running) do
    script = change(script, running: running, state: serialize(new_script_state))
    do_persist(script)
  end

  defp do_persist(script) do
    {:ok, script} = Repo.update(script)
    change(script, state: deserialize(script.state))
  end
end