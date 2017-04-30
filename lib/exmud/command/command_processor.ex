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

  defmodule Args do
    defstruct subject: nil, # The id of an object which the command is being executed on behalf of; Usually a player.
              command_string: nil # Raw input string being processed. Can be modified in place by preprocessors.
  end

  alias Exmud.CommandProcessorSup
  import Exmud.Utils
  use GenServer


  #
  # API
  #


  @doc """
  Submit a text command for processing in an asychronous manner.

  A reference is returned which can be used for identifying
  """
  def process(command_string, subject) do
    {:ok, pid} = Supervisor.start_child(CommandProcessorSup, [])
    ref = make_ref()
    :ok = GenServer.cast(pid, {:process, %Args{command_string: command_string, subject: subject}, self(), ref})
    {:ok, ref}
  end


  #
  # Worker callback
  #


  @doc false
  @spec start_link() :: {:ok, pid}
  def start_link, do: GenServer.start_link(__MODULE__, :ok)


  #
  # GenServer Callbacks
  #


  @doc false
  def init(_) do
    {:ok, %{}}
  end

  @doc false
  def handle_cast({:process, %Args{command_string: command_string, subject: subject} = _args, from, ref}, state) do
    # Run preprocessors
    # get context for subject via callback module
    #
    #
    #
    #
    #
    #
    #
    #
    send(from, {:command_processing_done, ref, :ok})
    {:stop, :normal, state}
  end


  #
  # Private Functions
  #


end
