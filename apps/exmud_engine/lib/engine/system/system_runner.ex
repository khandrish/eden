defmodule Exmud.Engine.SystemRunner do
  @moduledoc false

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
  def start_link(name, args) do
    case GenServer.start_link(__MODULE__, {name, args}, name: via(@system_registry, name)) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end


  #
  # Initialization of the GenServer and the system it is managing.
  #


  @doc false
  def init({name, args}) do
    # Either load the System from the database, or create a new System struct. This struct contains the state of the
    # System as understood by the callback, as well as information used by the Engine to execute the System properly.
    with {:ok, callback_module} <- Exmud.Engine.System.lookup(name),
         {:ok, loaded_system} <- load_system(name, callback_module, args)
    do
      start_system(loaded_system, args)
    else
      {:error, error} -> {:stop, error}
    end
  end

  defp load_system(name, callback_module, args) do
    case Repo.one(from(system in System, where: system.name == ^name)) do
      nil ->
        Logger.info("System `#{name}` not found in the database.")

        initialization_result = apply(callback_module, :initialize, [args])

        case initialization_result do
          {:ok, new_state} ->
            Logger.info("System `#{name}` successfully initialized.")

            {:ok, change(%System{}, callback_module: callback_module, name: name, state: new_state)}
          {_, error} = result ->
            Logger.error("Encountered error `#{error}` while initializing System `#{name}`.")

            result
        end
      system ->
        Logger.info("System `#{name}` loaded from database.")

        {:ok, change(system, callback_module: callback_module, state: deserialize(system.state))}
    end
  end

  defp start_system(system, start_args) do
    start_result = apply(get_field(system, :callback_module),
                         :start,
                         [get_field(system, :state), start_args])

    if elem(start_result, 0) == :ok do
      Logger.info("System `#{get_field(system, :name)}` successfully started.")

      system = change(system, state: serialize(elem(start_result, 1)))

      # Save modified state immediately
      {:ok, system} = Repo.insert_or_update(System.cast(system))
      system = change(system, state: deserialize(system.state))

      # If an interval was returned, trigger run after said interval
      if :erlang.tuple_size(start_result) == 3, do: Process.send_after(self(), :auto_run, elem(start_result, 2))

      {:ok, system}
    else
      {_, error, new_state} = start_result

      Logger.error("Encountered error `#{error}` while starting System `#{get_field(system, :name)}`.")

      Repo.insert_or_update(change(system, state: new_state))

      {:stop, error}
    end
  end

  @doc false
  def handle_call(:run, _from, system) do
    Process.send_after(self(), :auto_run, 0)
    {:reply, {:ok, :running}, system}
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
        Logger.info("System `#{get_field(system, :name)}` successfully stopped.")

        system = update_and_persist(system, new_state)

        {:stop, :normal, {:ok, :stopped}, system}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when stopping System `#{get_field(system, :name)}`.")

        system = update_and_persist(system, new_state)

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
        Logger.info("System `#{get_field(system, :name)}` successfully ran.")

        {:noreply, update_and_persist(system, new_state)}
      {:ok, new_state, interval} ->
        Logger.info("System `#{get_field(system, :name)}` successfully ran. Running again in #{interval} milliseconds.")

        Process.send_after(self(), :auto_run, interval)

        {:noreply, update_and_persist(system, new_state)}
      {:error, error, new_state} ->
        Logger.error("Error `#{error}` encountered when running System `#{get_field(system, :name)}`.")

        {:noreply, update_and_persist(system, new_state)}
      {:error, error, new_state, interval} ->
        Logger.error("Error `#{error}` encountered when running System `#{get_field(system, :name)}`.  Running again in #{interval} milliseconds.")

        Process.send_after(self(), :auto_run, interval)

        {:noreply, update_and_persist(system, new_state)}
      {:stop, reason, new_state} ->
        Logger.info("System `#{get_field(system, :name)}` stopping after run.")

        stop_result = apply(get_field(system, :callback_module),
                            :stop,
                            [reason, new_state])

        system_state =
          case stop_result do
            {:ok, system_state} ->
              Logger.info("System `#{get_field(system, :name)}` successfully stopped.")
              system_state
            {:error, error, system_state} ->
              Logger.error("Error `#{error}` encountered when stopping System `#{get_field(system, :name)}`.")
              system_state
          end

        system = update_and_persist(system, system_state)

        {:stop, :normal, system}
    end
  end


  #
  # Private Functions
  #

  defp update_and_persist(system, new_system_state) do
    system = change(system, state: serialize(new_system_state))
    {:ok, system} = Repo.update(system)
    change(system, state: deserialize(system.state))
  end
end