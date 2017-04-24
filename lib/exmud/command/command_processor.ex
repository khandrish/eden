defmodule Exmud.CommandProcessor do
  @moduledoc """
  This module handles the lifecycle of a command which is being processed.

  When an `Exmud.PlayerSession` process submits a command for processing, a
  new `Exmud.CommandProcessor` is spawned. This processor is responsible for querying
  for the correct callback modules and driving the execution of the command.

  The submission process is asychronous, with the spawned processor sending a message
  back to the process which submitted the command indicating that processing has
  finished and returning the final command object.
  """

  defmodule State do
    defstruct active_input: nil, # Input being processed.
              active_task: nil, # Task processing input.
              event_manager: nil, # Event manager for output stream.
              input_queue: EQueue.new(), # Holds all input waiting to be processed.
              key: nil, # The unique key identifying the player that the session represents.
              message_queue: EQueue.new(), # Holds all output waiting to be sent, only populated if no listeners.
              start_time: nil # The time the session was started
  end

  alias Exmud.CommandProcessorSupervisor
  import Exmud.Utils
  use GenServer


  #
  # API
  #


  @doc """
  Submit a text command for processing in an asychronous manner.

  A reference is returned which can be used for identifying
  """
  def process(command) do
    {:ok, pid} = Supervisor.start_child(CommandProcessorSupervisor, [])
    ref = make_ref()
    :ok = GenServer.cast(pid, {:process, command, self(), ref})
    {:ok, ref}
  end


  #
  # Worker callback
  #


  @doc false
  @spec start_link(any) :: {:ok, pid}
  def start_link(_), do: GenServer.start_link(__MODULE__, :ok)


  #
  # GenServer Callbacks
  #


  @doc false
  def init(_) do
    {:ok, %{}}
  end

  @doc false
  def handle_cast({:process, command, from, ref}, state) do
    # do command processing type stuff here
    send(from, {:command_processing_done, ref, :ok, command})
    {:stop, :normal, :ok, state}
  end


  #
  # Private Functions
  #


end
