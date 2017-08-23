defmodule Exmud.Engine.SystemRunner do
  @moduledoc false

  defmodule State do
    @moduledoc false
    defstruct running: false, system: nil
  end

  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.System
  import Ecto.Changeset
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger
  use GenServer

  @system_registry system_registry()


  #
  # Worker callback used by the supervisor when starting a new system runner.
  #


  @doc false
  def start_link(key, args) do
    case GenServer.start_link(__MODULE__, {key, args}, name: via(@system_registry, key)) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end


  #
  # Initialization of the GenServer and the system it is managing.
  #


  @doc false
  def init({key, args}) do
    # Either load the System from the database, or create a new System struct. This struct contains the state of the
    # System as understood by the callback, as well as information used by the Engine to execute the System properly.
    with {:ok, callback_module} <- Exmud.Engine.System.lookup(key),
         loaded_system <- load_system(key, callback_module),
         {:ok, initialized_system, initialized_args} <- initialize_system(loaded_system, args)
    do
      start_system(initialized_system, initialized_args)
    else
      {:error, error} -> {:stop, error}
    end
  end

  defp load_system(key, callback_module) do
    case Repo.one(from(system in System, where: system.key == ^key)) do
      nil ->
        Logger.info("System `#{key}` not found in the database.")

        change(%System{}, callback_module: callback_module, key: key, state: nil)
      system ->
        Logger.info("System `#{key}` loaded from database.")

        change(system, callback_module: callback_module, initialized: true, state: deserialize(system.state))
    end
  end

  defp initialize_system(system, args) do
    if get_field(system, :initialized) do
      Logger.info("System `#{get_field(system, :key)}` already initialized.")

      {:ok, system, args}
    else
      initialization_result = apply(get_field(system, :callback_module), :initialize, [args])

      case initialization_result do
        {:ok, new_state} ->
          Logger.info("System `#{get_field(system, :key)}` successfully initialized. Returning passed in args.")

          {:ok, change(system, state: new_state), args}
        {_, error} = result ->
          Logger.error("Encountered error `#{error}` while initializing System `#{get_field(system, :key)}`.")

          result
      end
    end
  end

  defp start_system(system, start_args) do
    start_result = apply(get_field(system, :callback_module),
                         :start,
                         [get_field(system, :state), start_args])

    if elem(start_result, 0) == :ok do
      Logger.info("System `#{get_field(system, :key)}` successfully started.")

      # Update the running status...or not
      system =
        case start_result do
          {_, new_state} ->
            change(system, state: serialize(new_state))
          {_, new_state, _} ->
            change(system, running: true, state: serialize(new_state))
        end

      # Save modified state immediately
      {:ok, system} = Repo.insert_or_update(System.cast(system))
      system = change(system, state: deserialize(system.state))

      # If an interval was returned, trigger run after said interval
      if get_field(system, :running), do: Process.send_after(self(), :auto_run, elem(start_result, 2))

      {:ok, system}
    else
      {_, error, new_state} = start_result

      Logger.error("Encountered error `#{error}` while starting System `#{get_field(system, :key)}`.")

      Repo.insert_or_update(change(system, state: new_state))

      {:stop, error}
    end
  end

  @doc false
  def handle_call(:start_running, _from, system) do
    if get_field(system, :running) do
      {:reply, {:error, :already_running}, system}
    else
      Process.send_after(self(), :auto_run, 0)

      {:reply, {:ok, :running}, change(system, running: true)}
    end
  end

  @doc false
  def handle_call({:message, message}, _from, system) do
    message_result = apply(get_field(system, :callback_module),
                           :handle_message,
                           [message, get_field(system, :state)])

    case message_result do
      {:ok, response, new_state} ->
        {:reply, {:ok, response}, update_and_persist(system, new_state)}
      {:error, error, new_state} ->
        {:reply, {:error, error}, update_and_persist(system, new_state)}
    end
  end

  @doc false
  def handle_call(:state, _from, system) do
    {:reply, {:ok, get_field(system, :state)}, system}
  end

  @doc false
  def handle_call({:stop, args}, _from, system) do
    stop_result = apply(get_field(system, :callback_module),
                        :stop,
                        [args, get_field(system, :state)])

    case stop_result do
      {:ok, new_state} ->
        Logger.info("System `#{get_field(system, :key)}` successfully stopped.")

        system = update_and_persist(system, new_state, false)

        {:stop, :normal, {:ok, :stopped}, system}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when stopping System `#{get_field(system, :key)}`.")

        system = update_and_persist(system, new_state, false)

        {:stop, :normal, {:error, error}, system}
    end
  end

  @doc false
  def handle_cast({:message, message}, system) do
    {_type, _response, new_state} = apply(get_field(system, :callback_module),
                                          :handle_message,
                                          [message, get_field(system, :state)])

    {:noreply, update_and_persist(system, new_state)}
  end

  @doc false
  def handle_info(:auto_run, system) do
    run_result = apply(get_field(system, :callback_module),
                                 :run,
                                 [get_field(system, :state)])

    case run_result do
      {:ok, new_state} ->
        Logger.info("System `#{get_field(system, :key)}` successfully ran.")

        {:noreply, update_and_persist(system, new_state, false)}
      {:ok, new_state, interval} ->
        Logger.info("System `#{get_field(system, :key)}` successfully ran. Running again in #{interval} milliseconds.")

        Process.send_after(self(), :auto_run, interval)

        {:noreply, update_and_persist(system, new_state, true)}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when running System `#{get_field(system, :key)}`.")

        {:noreply, update_and_persist(system, new_state, false)}
      {:error, error, new_state, interval} ->
        Logger.error("Error `#{error}` encountered when running System `#{get_field(system, :key)}`.  Running again in #{interval} milliseconds.")

        Process.send_after(self(), :auto_run, interval)

        {:noreply, update_and_persist(system, new_state, true)}
      {:stop, reason, new_state} ->
        Logger.info("System `#{get_field(system, :key)}` stopping after run.")


        stop_result = apply(get_field(system, :callback_module),
                            :stop,
                            [reason, new_state])



        system_state =
          case stop_result do
            {:ok, system_state} ->
              Logger.info("System `#{get_field(system, :key)}` successfully stopped.")
              system_state
            {:error, error, system_state} ->
              Logger.error("Error `#{error}` encountered when stopping System `#{get_field(system, :key)}`.")
              system_state
          end

        system = update_and_persist(system, system_state, false)

        {:stop, :normal, system}
    end
  end


  #
  # Private Functions
  #

  defp update_and_persist(system, new_system_state) do
    system = change(system, state: serialize(new_system_state))
    do_persist(system)
  end

  defp update_and_persist(system, new_system_state, running) do
    system = change(system, running: running, state: serialize(new_system_state))
    do_persist(system)
  end

  defp do_persist(system) do
    {:ok, system} = Repo.update(system)
    change(system, state: deserialize(system.state))
  end
end