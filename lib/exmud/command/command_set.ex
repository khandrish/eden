defmodule Exmud.CommandSet do
  @moduledoc """
  A command set determines what commands an object has attached to it.

  An `Exmud.Object` can have an arbitrary number of command sets associated with it.

  A command set is a module which implements the `Exmud.CommandSet` behavior. When a command string is bring processed,
  the engine gathers the relevant command sets from the current context and merges them together to form a single
  command set. The incoming command string is then checked against the commands in this final command set, using both
  their keys and aliases, and then an appropriate action is taken whether it be executing a command or returning an
  error.

  Note than when determining whether commands match during a merge, both the keys and aliases will be checked and any
  match will mean two commands are treated as the same.
  """

  alias Exmud.CommandSetTemplate, as: CST
  alias Exmud.CommandTemplate
  alias Exmud.Object
  alias Exmud.Repo
  alias Exmud.Schema.CommandSet, as: CS
  import Exmud.Utils
  require Logger

  @command_set_category "command_set"


  #
  # API
  #


  @doc """
  Given an `%Exmud.CommandSetTemplate{}` struct and the object to which it belongs, all commands contained in the
  command set are iterated over and initialized.

  This includes injecting the object that the command set belongs to so that the relationship doesn't get lost in the
  combining of command sets.
  """
  def initialize_commands(command_set_template) do
    initialized_commands =
      Enum.reduce(command_set_template.commands, MapSet.new(), fn(command_handler, mapset) ->
        command_template =
          CommandTemplate.new()
          |> CommandTemplate.set_handler(command_handler)
          |> CommandTemplate.set_object(command_set_template.object)
          |> command_handler.init()

        MapSet.put(mapset, command_template)
      end)

    %{command_set_template | commands: initialized_commands}
  end

  def merge(%CST{priority: dominant_priority} = dominant_command_set,
            %CST{priority: recessive_priority} = recessive_command_set) when dominant_priority > recessive_priority do
    do_merge(recessive_command_set, dominant_command_set)
  end

  def merge(%CST{priority: recessive_priority} = recessive_command_set,
            %CST{priority: dominant_priority} = dominant_command_set) when dominant_priority >= recessive_priority do
    do_merge(recessive_command_set, dominant_command_set)
  end


  #
  # Private functions
  #


  # Given a command struct, create a map where the keys are the combined aliases and command key and all of the values
  # are the command struct itself.
  @lint {Credo.Check.Refactor.PipeChainStart, false}
  defp create_commands_map(commands) do
    Enum.reduce(commands, %{}, fn(command, map) ->
      Enum.reduce(command.aliases, map, fn(a, mapping) ->
        Map.put(mapping, a, command)
      end)
      |> Map.put(command.key, command)
    end)
  end

  # Perform the merge of two command sets.
  defp do_merge(recessive_cs, dominant_cs) do
    merge_type = get_merge_type(dominant_cs, recessive_cs.callback_module)

    conflicts = find_conflicting_commands(recessive_cs.commands, dominant_cs.commands)

    commands = do_merge(recessive_cs.commands,
                        dominant_cs.commands,
                        conflicts,
                        merge_type,
                        dominant_cs.allow_duplicates)

    %{dominant_cs | commands: commands}
  end

  # Perform a union merge when no duplicates are allowed.
  defp do_merge(recessive_commands, dominant_commands, conflicts, :union, false) do
    filtered_recessive_commands = filter_commands(recessive_commands, conflicts, 0)
    MapSet.union(filtered_recessive_commands, dominant_commands)
  end

  # Perform a union merge when duplicates are allowed.
  defp do_merge(recessive_commands, dominant_commands, _, :union, true) do
    MapSet.union(recessive_commands, dominant_commands)
  end

  # Perform an intersection merge when duplicates are not allowed.
  defp do_merge(recessive_commands, dominant_commands, conflicts, :intersect, false) do
    Enum.reduce(conflicts, MapSet.new(), &(MapSet.put(&2, elem(&1, 1))))
  end

  # Perform an intersection merge when duplicates are allowed.
  defp do_merge(recessive_commands, dominant_commands, conflicts, :intersect, true) do
    Enum.reduce(conflicts, MapSet.new(), fn({recessive_command, dominant_command}, map) ->
      map
      |> MapSet.put(dominant_command)
      |> MapSet.put(recessive_command)
    end)
  end

  # Perform a remove merge where the matching commands from the higher priority command set are removed from the lower
  # priority command set.
  defp do_merge(recessive_commands, dominant_commands, conflicts, :remove, _) do
    filter_commands(recessive_commands, conflicts, 0)
  end

  # Perform a replace merge where the dominant command set completely replaces the recessive one without even checking
  # for matches.
  defp do_merge(_, dominant_commands, _, :replace, _) do
    dominant_commands
  end

  # Given a set of commands, a tuple of recessive/dominant commands in conflict, and an index specifying which of the
  # conflicting commands to use, filter the provided set of commands.
  defp filter_commands(commands, conflicts, index) do
    conflicting_commands = Enum.reduce(conflicts, MapSet.new(), &(MapSet.put(&2, elem(&1, index))))
    MapSet.difference(commands, conflicting_commands)
  end

  # Given two command sets, find the commands that would cause duplicate match errors and  return the commands from both
  # sets that caused the error.
  defp find_conflicting_commands(recessive_cs, dominant_cs) do
    recessive_commands_mapping = create_commands_map(recessive_cs)
    dominant_commands_mapping = create_commands_map(dominant_cs)

    all_recessive_keys = MapSet.new(Map.keys(recessive_commands_mapping))
    all_dominant_keys = MapSet.new(Map.keys(dominant_commands_mapping))

    Enum.reduce(all_recessive_keys, MapSet.new(), fn(key, conflicting_commands) ->
      if MapSet.member?(all_dominant_keys, key) do
        MapSet.put(conflicting_commands, {recessive_commands_mapping[key], dominant_commands_mapping[key]})
      else
        conflicting_commands
      end
    end)
  end

  # Given a command set and a key against which to check, determine what the merge type should be.
  defp get_merge_type(command_set, key) do
    command_set.merge_type_overrides
    |> Map.keys()
    |> MapSet.new()
    |> MapSet.member?(key)
    |> if do
      command_set.merge_type_overrides[key]
    else
      command_set.merge_type
    end
  end
end
