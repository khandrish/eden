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
              command_string: nil # Raw input string being processed. Can be modified in place by transformers.
  end

  alias Ecto.Multi
  alias Exmud.Callback
  alias Exmud.Command
  alias Exmud.CommandProcessorSup
  alias Exmud.CommandSet
  alias Exmud.CommandSetTemplate
  alias Exmud.CommandTemplate
  alias Exmud.Object
  alias Exmud.Repo
  import Exmud.Utils
  require Logger
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
    GenServer.call(pid, {:process, %Args{command_string: command_string, subject: subject}})
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
  def handle_call({:process, %Args{command_string: command_string, subject: subject} = _args}, _from, state) do
    try do
      prepare_multi(subject, command_string)
      |> Repo.transaction()
      |> case do
        {:ok, results} ->
          {:stop, :normal, {:ok, results}, state}
        {:error, failed_function, failed_value, _successful_changes} ->
          {:stop, :normal, {:error, {failed_function, failed_value}}, state}
      end
    rescue
      e ->
        {:stop, :normal, {:error, e}, state}
    end
  end


  #
  # Private Functions
  #

  defp determine_context(subject) do
    objects =
      case Object.get_callback(subject, "__command_context") do
        {:ok, callback} -> callback
        _error -> {:ok, callback} = Callback.which_module("__command_context")
          callback
      end
      |> apply(:run, [subject])

    if is_list(objects) and length(objects) > 0 do
      Logger.debug("Objects which make up the context for object #{subject}: #{inspect(objects)}")
      {:ok, objects}
    else
      {:error, :no_context}
    end
  end

  defp do_match(subject, commands, match_string) do
    matching_commands = match_commands(commands, match_string, false)

    if length(matching_commands) > 0 do
      command = List.first(matching_commands)
      {:ok, command}
    else
      case Callback.which_module(match_string) do
        {:ok, callback_module} ->
          {:ok, CommandTemplate.init(subject, callback_module)}
        _error ->
          Logger.error("No command callback module could be found.")
          {:error, :no_command_found}
      end
    end
  end

  defp extract_command(subject, match_string, command_set) do
    matching_commands = match_commands(command_set.commands, match_string)

    case length(matching_commands) do
      1 ->
        [command] = matching_commands
        {:ok, command}
      0 ->
        do_match(subject, command_set.commands, "__CMD_NO_MATCH")
      _ ->
        do_match(subject, command_set.commands, "__CMD_MULTI_MATCH")
    end
  end

  defp execute_command(command, subject, match_string, command_string) do
    Logger.debug("Executing command: #{inspect(command)}")

    try do
      parse_string = String.slice(command_string, String.length(match_string) + 1, String.length(command_string))

      case command.callback_module.parse(parse_string) do
        {:ok, args} ->
          command_args =
            Command.new()
            |> Command.set_subject(subject)
            |> Command.set_match_string(match_string)
            |> Command.set_args(args)

          command.callback_module.run(command_args)
        error ->
          error
      end
    rescue
      e ->
        {:error, e}
    end
  end

  defp extract_match_string(command_string) do
    Logger.debug("Extracting match string from: #{inspect(command_string)}")

    match_string =
      String.split(command_string)
      |> List.first()

    Logger.debug("Match string: #{inspect(match_string)}")
    {:ok, match_string}
  end

  defp fetch_context(context) do
    case Object.get(context, :command_sets) do
      {:ok, objects} ->
        if length(context) == length(objects) do
          {:ok, sort_objects(objects, context)}
        else
          if length(objects) == 0 do
            {:error, :no_objects_retrieved}
          else
            missing_context =
              Enum.reduce(objects, MapSet.new(context), fn(object, context) ->
                if MapSet.contains?(object.id) do
                  MapSet.delete(context, object.id)
                else
                  context
                end
              end)

            Enum.each(missing_context, fn(object_id) ->
              Logger.error("Could not retrieve context object {#{inspect(object_id)}} when processing command")
            end)

            context = MapSet.to_list(MapSet.difference(MapSet.new(context), MapSet.new(missing_context)))

            {:ok, sort_objects(objects, context)}
          end
        end
      error ->
        error
    end
  end

  defp initialize_command_sets(objects) do
    command_set_templates =
      objects
      # For every object
      |> Enum.map(fn(object) ->
        object.command_sets
        # Initialize each command set by calling callback module's init/1 function
        |> Enum.map(fn(command_set) ->
          command_set_template =
            CommandSetTemplate.new()
            |> CommandSetTemplate.set_object(command_set.oid)
            |> CommandSetTemplate.set_callback_module(command_set.callback_module)
            |> command_set.callback_module.init()
            |> CommandSet.initialize_commands()
        end)
        |> sort_command_sets_by_priority_and_insertion()
      end)
      |> Enum.filter(&(length(&1) > 0))

    Logger.debug("Command set templates: #{inspect(command_set_templates)}")
    if length(command_set_templates) > 0 do
      {:ok, command_set_templates}
    else
      # callback/engine hook here for custom error handling?
      {:error, :no_command_sets}
    end
  end

  defp merge_command_sets(templates) do
    Logger.debug("Templates before merging: #{inspect(templates)}")

    merged_command_set =
      templates
      |> Enum.map(&(do_command_set_merge(&1)))
      |> sort_command_sets_by_priority()
      |> do_command_set_merge()

    Logger.debug("Merged command set: #{inspect(merged_command_set)}")
    {:ok, merged_command_set}
  end

  # transformers
  # parser
  # handler
  # context

  defp prepare_multi(subject, command_string) do
    # Multi.new()
    # # Run transformers
    # |> Multi.run(:transformers, fn(_) -> run_transformers(subject, command_string) end)
    # # Extract match string
    # |> Multi.run(:match_string, fn(%{transformers: cmd_string}) -> extract_match_string(cmd_string) end)
    # # Gather Context
    # |> Multi.run(:context, fn(_) -> determine_context(subject) end)
    # # Fetch command sets for objects making up context
    # |> Multi.run(:objects, fn(%{context: context}) -> fetch_context(context) end)
    # # Initialize the retrieved command sets including commands
    # |> Multi.run(:command_sets, fn(%{objects: objects}) -> initialize_command_sets(objects) end)
    # # Merge command sets
    # |> Multi.run(:merge_command_sets, fn(%{command_sets: templates}) -> merge_command_sets(templates) end)
    # # Determine which single command to execute.
    # |> Multi.run(:match_command, fn(%{merge_command_sets: command_set, match_string: match_string}) ->
    #   extract_command(subject, match_string, command_set)
    # end)
    # # Execute command
    # |> Multi.run(:execute_command, fn(%{match_command: command, match_string: match_string, transformers: cmd_string}) ->
    #   execute_command(command, subject, match_string, cmd_string)
    # end)
    command_string
  end

  defp match_commands(commands, match_string, transform \\ true) do
    match_string = if (transform), do: String.downcase(match_string), else: match_string

    Enum.reduce(commands, MapSet.new(), fn(command, matches) ->
      keys = MapSet.put(command.aliases, command.key)
      if MapSet.member?(keys, match_string) do
        MapSet.put(matches, command)
      else
        matches
      end
    end)
    |> MapSet.to_list()
  end

  defp do_command_set_merge([command_set]) do
    command_set
  end

  defp do_command_set_merge([command_set_a | [command_set_b | rest]]) do
    do_command_set_merge([CommandSet.merge(command_set_a, command_set_b) | rest])
  end

  defp run_transformers(subject, command_string) do
    Logger.debug("Command string before preprocessing: #{inspect(command_string)}")

    new_command_string =
      case Object.get_callback(subject, "__command_string_transformers") do
        {:ok, callbacks} -> callbacks
        _error ->
          {:ok, callbacks} = Callback.which_module("__command_string_transformers")
          callbacks
      end
      |> List.wrap()
      |> Enum.reduce(command_string, &(apply(&1, :run, [&2])))

    Logger.debug("Command string after preprocessing: #{inspect(new_command_string)}")
    {:ok, new_command_string}
  end

  defp sort_command_sets_by_priority(command_sets) do
    Enum.sort(command_sets, &(&1.priority > &2.priority))
  end

  defp sort_command_sets_by_priority_and_insertion(command_sets) do
    Enum.sort(command_sets, fn(command_set_a, command_set_b) ->
      cond do
        command_set_a.priority > command_set_b.priority ->
          true
        command_set_a.priority == command_set_b.priority and command_set_a.inserted_at <= command_set_b.inserted_at ->
          true
        true ->
          false
      end
    end)
  end

  defp sort_objects(objects, context) do
    object_map =
      Enum.reduce(objects, %{}, fn(object, map) ->
        Map.put(map, object.id, object)
      end)

    Enum.map(context, fn(object_id) ->
      Map.get(object_map, object_id)
    end)
  end
end
