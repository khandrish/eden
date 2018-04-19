defmodule Exmud.Engine.CommandSet do
  @moduledoc """
  Command Sets not only allow Commands to be added to/removed from Objects in bulk, but they define the rules by which
  multiple Command Sets on an Object can be merged to present a final unified set of Commands for further processing.
  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.CommandSet

      @doc false
      def name, do: Atom.to_string(__MODULE__)

      @doc false
      def commands(_config), do: []

      @doc false
      def merge_priority(_config), do: 1

      @doc false
      def merge_type(_config), do: :union

      @doc false
      def merge_keys(config), do: commands(config)

      @doc false
      def merge_overrides(_config), do: %{}

      @doc false
      def merge_duplicates(_config), do: false

      @doc false
      def merge_name(_config), do: name()

      @doc false
      def merge_function(_config), do: &(&1.name == &2.name)

      defoverridable commands: 1,
                     merge_priority: 1,
                     merge_type: 1,
                     name: 0,
                     merge_keys: 1,
                     merge_overrides: 1,
                     merge_duplicates: 1,
                     merge_name: 1,
                     merge_function: 1
    end
  end

  @doc """
  The name of the Script.
  """
  @callback name :: String.t()

  @doc """
  The function used to compare one key to another to determine equality when being merged.
  """
  @callback merge_function(key, key) :: boolean

  @doc """
  The merge type to use when being merged, unless an override matches in which case that is used instead.
  Default to ':union'
  """
  @callback merge_type(config) :: merge_type

  @doc """
  The overrides to check against when determining merge_type. If any match the name of a lower priority CommandSet, the
  specified merge type will be used instead of what is returned by 'merge_type/1'
  """
  @callback merge_overrides(config) :: merge_type

  @doc """
  The keys to be merged.
  """
  @callback merge_keys(config) :: [key]

  @doc """
  The name to use when checking for overrides. Defaults to the name of the CommandSet as provided by 'name/1'.
  """
  @callback merge_name(config) :: String.t()

  @doc """
  The generated list of commands that are contained in the Command Set.
  """
  @callback commands(config) :: [term]

  @doc """
  The priority of the CommandSet when being merged. Default is 1.
  """
  @callback merge_priority(config) :: integer

  @typedoc "Configuration passed through to a callback module."
  @type config :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "Id of the Object the Command Set is attached to."
  @type object_id :: integer

  @typedoc "The name of the Command Set as registered with the Engine."
  @type name :: String.t()

  @typedoc "A Command to be executed by the Engine."
  @type command :: term

  @typedoc "A key to be merged."
  @type key :: term

  @typedoc "The callback_module that is the implementation of the Command Set logic."
  @type callback_module :: atom

  @typedoc "One of a finite set of types of merges that can take place."
  @type merge_type :: :union | :intersect | :remove | :replace

  @typedoc "The name of the Command Set as registered with the Engine."
  @type command_set_name :: String.t()

  alias Exmud.Engine.Cache
  alias Exmud.Engine.MergeSet
  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.CommandSet
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger

  #
  # API
  #

  @doc """
  Attach a Command Set to an Object.
  """
  @spec attach(object_id, command_set_name, config) ::
          :ok
          | {:error, :no_such_object}
          | {:error, :already_attached}
          | {:error, :no_such_command_set}
  def attach(object_id, command_set_name, config \\ nil) do
    with {:ok, _} <- lookup(command_set_name) do
      record =
        CommandSet.new(%{object_id: object_id, name: command_set_name, config: pack_term(config)})

      ObjectUtil.attach(record)
    end
  end

  @doc """
  Build the active list of Commands for an Object.

  The active list of Commands is the result of merging all Command Sets attached to an Object in a determanistic order.
  The oldest attached Command Set is used as the base, with increasingly newer Command Sets merged on top while still
  respecting priority. If the oldest Command Set also happens to have the highest priority, it will be merged last.
  """
  @spec build_active_command_list(object_id) :: [] | [command]
  def build_active_command_list(object_id) do
    query =
      from cs in command_set_query(object_id),
        select: {cs.name, cs.config},
        order_by: [asc: cs.inserted_at]

    case Repo.all(query) do
      [] ->
        []
      command_sets ->
        command_sets
        |> Stream.map(fn {name, config} ->
          case lookup(name) do
            {:ok, callback_module} ->
              build_merge_set(callback_module, config)
            _ ->
              Logger.error("Command Set '#{name}' found attached to Object '#{object_id}' with no corresponding registered Command Set")
              nil
          end
        end)
        |> Stream.reject(&(&1 == nil))
        |> Enum.sort(&(&1.priority >= &2.priority))
        |> Enum.reduce(MergeSet.new(), fn (higher_priority_merge_set, lower_priority_merge_set) ->
          MergeSet.merge(higher_priority_merge_set, lower_priority_merge_set)
        end)
        |> (&(&1.keys)).()
    end
  end

  @spec build_merge_set(callback_module, config) :: term
  defp build_merge_set(callback_module, config) do
    MergeSet.new(
      allow_duplicates: callback_module.merge_duplicates(config),
      function: callback_module.merge_function(config),
      keys: callback_module.merge_keys(config),
      name: callback_module.merge_name(config),
      overrides: callback_module.merge_overrides(config),
      priority: callback_module.merge_priority(config),
      merge_type: callback_module.merge_type(config)
    )
  end

  @doc """
  Check to see if an Object has all of the provided Command Sets attached.
  """
  @spec has_all?(object_id, command_set_name | [command_set_name]) :: boolean
  def has_all?(object_id, command_set_names) do
    command_set_names = List.wrap(command_set_names)

    query =
      from(command_set in command_set_query(object_id, command_set_names), select: count("*"))

    Repo.one(query) == length(command_set_names)
  end

  @doc """
  Check to see if an Object has any of the provided Command Sets attached.
  """
  @spec has_any?(object_id, command_set_name | [command_set_name]) :: boolean
  def has_any?(object_id, command_set_names) do
    command_set_names = List.wrap(command_set_names)

    query =
      from(command_set in command_set_query(object_id, command_set_names), select: count("*"))

    Repo.one(query) > 0
  end

  @doc """
  Detach one or more Command Sets from an Object atomically. If one cannot be detached, none will be.
  """
  @spec detach(object_id, command_set_name | [command_set_name]) :: :ok | :error
  def detach(object_id, command_set_names) do
    command_set_names = List.wrap(command_set_names)

    Repo.transaction(fn ->
      command_set_query(object_id, command_set_names)
      |> Repo.delete_all()
      |> case do
        {number_deleted, _} when number_deleted == length(command_set_names) -> :ok
        _ -> Repo.rollback(:error)
      end
    end)
    |> elem(1)
  end

  @doc """
  Detach one or more Command Sets from an Object.

  No attempt will be made to validate how many were actually detached, making this method more useful for
  fire-and-forget type deletes where some or all of the Command Sets may not actually exist on the Object
  """
  @spec detach!(object_id, command_set_name | [command_set_name]) :: :ok
  def detach!(object_id, command_set_names) do
    command_set_names = List.wrap(command_set_names)

    command_set_query(object_id, command_set_names)
    |> Repo.delete_all()

    :ok
  end

  @spec command_set_query(object_id, [command_set_name]) :: term
  defp command_set_query(object_id, command_set_names) do
    from(
      command_set in CommandSet,
      where: command_set.name in ^command_set_names and command_set.object_id == ^object_id
    )
  end

  @spec command_set_query(object_id) :: term
  defp command_set_query(object_id) do
    from(
      command_set in CommandSet,
      where: command_set.object_id == ^object_id
    )
  end

  #
  # Manipulation of Command Sets in the Engine.
  #

  @cache :command_set_cache

  @doc """
  List all Command Sets which are currently registered with the Engine.
  """
  @spec list_registered :: [] | [callback_module]
  def list_registered() do
    Logger.info("Listing all registered Command Sets")
    Cache.list(@cache)
  end

  @doc """
  Lookup the callback module for the Command Set with the provided name.
  """
  @spec lookup(name) :: {:ok, callback_module} | {:error, :no_such_command_set}
  def lookup(name) do
    case Cache.get(@cache, name) do
      {:error, _} ->
        Logger.error("Lookup failed for Command Set registered with name `#{name}`")
        {:error, :no_such_command_set}

      result ->
        Logger.info("Lookup succeeded for Command Set registered with name `#{name}`")
        result
    end
  end

  @doc """
  Register a callback module for a Command Set with the provided name.
  """
  @spec register(callback_module) :: :ok
  def register(callback_module) do
    name = callback_module.name()

    Logger.info(
      "Registering Command Set with name `#{name}` and module `#{inspect(callback_module)}`"
    )

    Cache.set(@cache, callback_module.name(), callback_module)
  end

  @doc """
  Check to see if a Command Set has been registered with the provided name.
  """
  @spec registered?(callback_module) :: boolean
  def registered?(callback_module) do
    Logger.info("Checking registration of Command Set with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregisters the callback module for a Command Set with the provided name.
  """
  @spec unregister(callback_module) :: :ok
  def unregister(callback_module) do
    Logger.info("Unregistering Command Set with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end
end
