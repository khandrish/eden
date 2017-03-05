defmodule Exmud.CommandSet do
  @moduledoc """
  A command set determines what commands a player has access to.

  An `Exmud.GameObject` can have an arbitrary number of command sets associated
  with it.

  A command set, in this context, is a module which implements the
  `Exmud.CommandSet` behavior. This command set can only be used once it is
  registered with the engine and a command set object has been initialized.
  When a command is sent by a player, the engine gathers the relevant command
  sets from the current context and merges them together to form a single
  command set. The incoming command is then checked against the commands,
  using both their keys and aliases, and then executed, or not, as logic
  dictates.

  Please note than when determining whether commands match during a merge,
  both the keys and aliases will be checked and any match will mean two
  commands are treated as the same.
  """


  #
  # Behavior definition
  #


  @doc """
  Initialize a new command set.

  All custom logic to build a command set takes place here. In most cases
  this involves creating a command set object and adding the desired commands.
  In complex cases a dynamic command set can be built if the desired effect
  can't be achieved with the normal merge rules and options.

  The 'init' method is only called with an object id if the command set was
  registered as a dynamic command set, and will be called with an explicit
  nil otherwise. Dynamic command sets will have their init method called each
  time the command set is accessed. See the docs on the registration function
  for the full warning.
  """
  @callback init(object) :: {:ok, command_set} | {:error, reason}

  @typedoc "The id of the object that the command set is being built for."
  @type object :: term | nil

  @typedoc "A command set object."
  @type command_set :: term

  @typedoc "The reason for the failure."
  @type reason :: term


  alias Exmud.GameObject
  alias Exmud.Registry
  alias Exmud.Repo
  alias Exmud.Schema.CommandSet, as: CS
  import Ecto.Query
  import Exmud.Utils
  require Logger

  @command_set_category "command_set"

  defstruct allow_duplicates: false,
            commands: MapSet.new(),
            merge_type: :union,
            merge_type_overrides: %{},
            priority: 0


  #
  # API
  #


  # Management of command sets within the engine

  @doc """
  In order for the engine to map command sets to command set objects or
  callback modules, each command set must be registered with the engine
  via a unique key.
  """
  def register(key, callback_module, dynamic \\ false)

  def register(key, callback_module, false) do
    Logger.debug("Initializing command set for key `#{key}` with module `#{callback_module}`")
    case callback_module.init(nil) do
      {:ok, command_set} ->
        Logger.debug("Registering static command set for key `#{key}` with module `#{callback_module}`")
        Registry.register_key(key, @command_set_category, {command_set, false})
      {:error, reason} = error ->
        Logger.error("Unable to initilize command set for key `#{key}` with module `#{callback_module} because `#{reason}`")
        error
    end
  end

  def register(key, callback_module, true) do
    Logger.debug("Registering dynamic command set for key `#{key}` with module `#{callback_module}`")
    Registry.register_key(key, @command_set_category, {callback_module, true})
  end

  def registered?(key) do
    Registry.key_registered?(key, @command_set_category)
  end

  def get(key, object \\ nil) do
    Logger.debug("Getting command set for key `#{key}`")
    case Registry.read_key(key, @command_set_category) do
      # Dynamic command set
      {:ok, {callback_module, true}} -> callback_module.init(object)
      # Static command set
      {:ok, {command_set, false}} -> {:ok, command_set}
      {:error, _} ->
        Logger.warn("Attempt to find callback module for command set with key `#{key}` failed")
        {:error, :no_such_command_set}
    end
  end

  def unregister(key) do
    Registry.unregister_key(key, @command_set_category)
  end

  # Manipulate commands on a command set

  def add_command(command_set, command) do
    %{command_set | commands: MapSet.put(command_set.commands, command)}
  end

  def has_command?(command_set, command), do: MapSet.member?(command_set.commands, command)

  def remove_command(command_set, command) do
    %{command_set | commands: MapSet.delete(command_set.commands, command)}
  end

  # Merge type overrides

  def add_override(command_set, key, merge_type) do
    %{command_set | merge_type_overrides: Map.put(command_set.merge_type_overrides, key, merge_type)}
  end

  def has_override?(command_set, key), do: Map.has_key?(command_set.merge_type_overrides, key)

  def remove_override(command_set, key) do
    %{command_set | merge_type_overrides: Map.delete(command_set.merge_type_overrides, key)}
  end

  # Merging command sets

  def merge(%Exmud.CommandSet{priority: priority1} = command_set1,
            %Exmud.CommandSet{priority: priority2} = command_set2) when priority1 >= priority2 do
    do_merge(command_set2, command_set1)
  end

  def merge(%Exmud.CommandSet{priority: priority1} = command_set1,
            %Exmud.CommandSet{priority: priority2} = command_set2) when priority1 < priority2 do
    do_merge(command_set1, command_set2)
  end

  # Other command set manipulation

  def new, do: %Exmud.CommandSet{}

  def set_allow_duplicates(command_set, maybe), do: %{command_set | allow_duplicates: maybe}

  def set_merge_type(command_set, merge_type), do: %{command_set | merge_type: merge_type}

  def set_priority(command_set, priority), do: %{command_set | priority: priority}


  #
  # Private functions
  #


  # Given a command struct, create a map where the keys are the combined aliases and
  # command set key and all of the values are the command struct itself.
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
  defp do_merge(old_cs, new_cs) do
    merge_type = get_merge_type(new_cs, old_cs.key)

    conflicts = find_conflicting_commands(old_cs.commands, new_cs.commands)

    do_merge(old_cs.commands, new_cs.commands, conflicts, merge_type, new_cs.allow_duplicates)
  end

  # Perform a union merge when no duplicates are allowed.
  defp do_merge(old_commands, new_commands, conflicts, :union, false) do
    filtered_old_commands = filter_commands(old_commands, conflicts, 0)
    MapSet.union(filtered_old_commands, new_commands)
  end

  # Perform a union merge when duplicates are allowed.
  defp do_merge(old_commands, new_commands, _, :union, true) do
    MapSet.union(old_commands, new_commands)
  end

  # Perform an intersection merge when duplicates are not allowed.
  defp do_merge(old_commands, new_commands, conflicts, :intersect, false) do
    Enum.reduce(conflicts, MapSet.new(), &(MapSet.put(&2, elem(&1, 1))))
  end

  # Perform an intersection merge when duplicates are allowed.
  defp do_merge(old_commands, new_commands, conflicts, :intersect, true) do
    Enum.reduce(conflicts, MapSet.new(), fn({old_command, new_command}, map) ->
      map
      |> MapSet.put(old_command)
      |> MapSet.put(new_command)
    end)
  end

  # Perform a remove merge where the matching commands from the higher priority
  # command set are removed from the lower priority command set.
  defp do_merge(old_commands, new_commands, conflicts, :remove, _) do
    filter_commands(old_commands, conflicts, 0)
  end

  # Perform a replace merge where the new command set completely replaces the
  # old one without even checking for matches.
  defp do_merge(_, new_commands, _, :replace, _) do
    new_commands
  end

  # Given a set of commands, a tuple of old/new commands in conflict, and an
  # index specifying which of the conflicting commands to use, filter the
  # provided set of commands.
  defp filter_commands(commands, conflicts, index) do
    conflicting_commands = Enum.reduce(conflicts, MapSet.new(), &(MapSet.put(&2, elem(&1, index))))
    MapSet.difference(commands, conflicting_commands)
  end

  # Given two command sets, find the commands that would cause duplicate match errors and
  # return the commands from both sets that caused the error.
  defp find_conflicting_commands(old_commands, new_commands) do
    old_commands_mapping = create_commands_map(old_commands)
    new_commands_mapping = create_commands_map(new_commands)

    all_old_keys = MapSet.new(Map.keys(old_commands_mapping))
    all_new_keys = MapSet.new(Map.keys(new_commands_mapping))

    Enum.reduce(all_new_keys, MapSet.new(), fn(key, conflicting_commands) ->
      if MapSet.member?(all_old_keys, key) do
        MapSet.put(conflicting_commands, {old_commands_mapping[key], new_commands_mapping[key]})
      else
        conflicting_commands
      end
    end)
  end

  # Given a command set and a key against which to check, determine what the
  # merge type should be.
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
