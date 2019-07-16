defmodule Exmud.Engine.CommandSet do
  @moduledoc """
  Command Sets represent a group of Commands.

  Command Sets not only allow Commands to be added to/removed from Objects in bulk, but they define the rules by which
  multiple Command Sets can be merged to present a final unified set of Commands for further processing.

  As in all cases of merging order does matter when merging Command Sets together, but the addition of the merge type,
  priority, and overrides impact the final product of a merge. In the case of priority, a Command Set with a higher
  priority will take precedence over one with a lower, otherwise if two Command Sets have the same priority the first
  one will be assumed to have a higher priority.

  Once priority has been determined, the merge type from the higher priority Command Set is selected and that merge type
  is used to perform the actual merge. If there is a merge type override in the higher priority Command Set which
  matches the name of the lower priority Command Set, that merge type will be used instead.

  The final Command Set created from the merger will take all of its properties, the keys being the exception, from the
  higher priority Command Set.

  There are four different types of merges possible:
    Union - All non-duplicate keys from both Command Sets end up in the final Command Set. The only merge type for which
            duplicates make sense.

            Example: ["foo", "bar"] + ["foobar", "barfoo"] == ["foo", "bar", "foobar", "barfoo"]

    Intersect - Only keys which exist in both Command Sets end up in the final Command Set. The key chosen will be from
                the higher priority Command Set.
            Example: ["foo", "bar"] + ["foo", "foobar", "barfoo"] == ["foo"]

    Replace - The higher priority keys replace the others, no matter if keys match or not.
            Example: ["foo", "bar"] + ["foobar", "barfoo"] == ["foo", "bar"]

    Remove - The higher priority keys replace the others, however any intersecting keys are first removed from the
             higher priority Command Set.
            Example: ["foo", "bar", "foobar"] + ["foobar", "barfoo"] == ["foo", "bar"]
  """

  @enforce_keys [:name, :priority]
  defstruct allow_duplicates: false,
            keys: [],
            priority: nil,
            merge_type: :union,
            callback_module: nil,
            overrides: %{}

  @type t :: %Exmud.Engine.CommandSet{
          allow_duplicates: boolean,
          keys: [term],
          priority: integer,
          merge_type: merge_type,
          callback_module: module,
          overrides: Map.t()
        }

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.CommandSet
      import Exmud.Engine.Constants

      @doc false
      @impl true
      def name(_config), do: Atom.to_string(__MODULE__)

      @doc false
      @impl true
      def commands(_config), do: []

      @doc false
      @impl true
      def merge_priority(_config), do: 1

      @doc false
      @impl true
      def merge_type(_config), do: :union

      @doc false
      @impl true
      def merge_overrides(_config), do: %{}

      @doc false
      @impl true
      def allow_duplicates(_config), do: false

      @doc false
      @impl true
      def visibility(_config), do: command_set_visibility_both()

      defoverridable commands: 1,
                     merge_priority: 1,
                     merge_type: 1,
                     merge_overrides: 1,
                     allow_duplicates: 1,
                     visibility: 1
    end
  end

  @doc """
  The name of the Command Set. This is a friendly name that can be used to help identify Command Sets in a UI and within the game.
  """
  @callback name(config) :: String.t()

  @doc """
  The merge type to use when being merged, unless an override matches in which case that is used instead.
  Defaults to ':union'
  """
  @callback merge_type(config) :: merge_type

  @doc """
  Determines whether or not to allow for duplicate Commands when merging. This defaults to 'false' but can be set to 'true' to allow for more complex behavior.
  """
  @callback allow_duplicates(config) :: merge_type

  @doc """
  The overrides to check against when determining merge_type. If any match the name of a lower priority CommandSet, the specified merge type will be used instead of what is returned by 'merge_type/1'
  """
  @callback merge_overrides(config) :: merge_type

  @doc """
  The list of commands that are contained in the Command Set.
  """
  @callback commands(config) :: [term]

  @doc """
  The priority of the CommandSet when being merged. Default is 1.
  """
  @callback merge_priority(config) :: integer

  @doc """
  The visibility of the Command Set. Can be one of '"internal" | "external" | "both"'. Defaults to '"both"'.
  """
  @callback visibility(config) :: visibility

  @typedoc "Configuration passed through to a callback module."
  @type config :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "Id of the Object the Command Set is attached to."
  @type object_id :: integer

  @typedoc "The name of the Command Set."
  @type name :: String.t()

  @typedoc "An Ecto query."
  @type query :: term

  @typedoc "A Command struct."
  @type command :: %Exmud.Engine.Command{}

  @typedoc "A key to be merged."
  @type key :: term

  @typedoc "The callback_module that is the implementation of the Command Set logic."
  @type callback_module :: atom

  @typedoc "One of a finite set of types of merges that can take place."
  @type merge_type :: :union | :intersect | :remove | :replace

  @typedoc "The visibility of the Command Set. Can be one of: internal, external, both."
  @type visibility :: String.t()

  alias Exmud.Engine.Command
  alias Exmud.Engine.Object
  alias Exmud.Engine.Schema.Object
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.CommandSet
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger
  import Exmud.Engine.Constants

  #
  # API for interacting with Objects
  #

  @doc """
  Attach a Command Set to an Object.
  """
  @spec attach(object_id, callback_module, config) ::
          :ok
          | {:error, :no_such_object}
          | {:error, :already_attached}
  def attach(object_id, callback_module, config \\ %{}) when is_map(config) do
    record =
      CommandSet.new(%{
        object_id: object_id,
        callback_module: callback_module,
        config: config,
        visibility: callback_module.visibility(config)
      })

    Object.attach(record)
  end

  @doc """
  Check to see if an Object has all of the provided Command Sets attached.
  """
  @spec has_all?(object_id, callback_module | [callback_module]) :: boolean
  def has_all?(object_id, command_set_callback_modules) do
    command_set_callback_modules = List.wrap(command_set_callback_modules)

    query =
      from(command_set in command_set_query(object_id, command_set_callback_modules),
        select: count("*")
      )

    Repo.one(query) == length(command_set_callback_modules)
  end

  @doc """
  Check to see if an Object has any of the provided Command Sets attached.
  """
  @spec has_any?(object_id, callback_module | [callback_module]) :: boolean
  def has_any?(object_id, command_set_callback_modules) do
    command_set_callback_modules = List.wrap(command_set_callback_modules)

    query =
      from(command_set in command_set_query(object_id, command_set_callback_modules),
        select: count("*")
      )

    Repo.one(query) > 0
  end

  @doc """
  Detach one or more Command Sets from an Object.
  """
  @spec detach(object_id, callback_module | [callback_module]) :: :ok
  def detach(object_id, command_set_callback_modules) do
    command_set_callback_modules = List.wrap(command_set_callback_modules)

    command_set_query(object_id, command_set_callback_modules)
    |> Repo.delete_all()

    :ok
  end

  #
  # API for interacting with CommandSet struct
  #

  @doc """
  Add a key to the Command Set
  """
  @spec add_key(%__MODULE__{}, key) :: %__MODULE__{}
  def add_key(command_set, key) do
    %{command_set | keys: List.insert_at(command_set.keys, -1, key)}
  end

  @doc """
  Check the Command Set to see if it already contains a key.
  """
  @spec has_key?(%__MODULE__{}, key) :: boolean
  def has_key?(command_set, key) do
    Enum.any?(command_set.keys, &(&1 == key))
  end

  @doc """
  Remove a key from the Command Set
  """
  @spec remove_key(%__MODULE__{}, key) :: %__MODULE__{}
  def remove_key(command_set, key) do
    %{command_set | keys: Enum.reject(command_set.keys, &(&1 == key))}
  end

  @doc """
  Add an override to the Command Set
  """
  @spec add_override(%__MODULE__{}, callback_module, merge_type) :: %__MODULE__{}
  def add_override(command_set, callback_module, merge_type) do
    %{command_set | overrides: Map.put(command_set.overrides, callback_module, merge_type)}
  end

  @doc """
  Remove an override to the Command Set
  """
  @spec remove_override(%__MODULE__{}, callback_module) :: %__MODULE__{}
  def remove_override(command_set, callback_module) do
    %{command_set | overrides: Map.delete(command_set.overrides, callback_module)}
  end

  @doc """
  Remove an override to the Command Set
  """
  @spec has_override?(%__MODULE__{}, callback_module) :: boolean
  def has_override?(command_set, callback_module) do
    Map.has_key?(command_set.overrides, callback_module)
  end

  @doc """
  Given either an '%Ecto.Query{}' struct that returns a list of Object ids, or a list of Object ids explicitly, build
  the list of Commands that the caller has access to.

  Given that every Command is executed in the context of a calling Object, and that Command Sets can have differing
  visibilities such as internal to an Object as is the case for many default Commands, a failure to include the calling
  Object in the context query could break an unknown number of things. Don't do it.

  ## Ecto query

  When providing an '%Ecto.Query{}' struct it's advisable to only return the object id as it will be used as a subquery.

  Example:
  '''
  context_query = from(
    object in Object,
    join: game_object_component in assoc(object, :components),
    where: game_object_component.object_id == object.id
      and game_object_component.name == "GameObjectLocation"
      and fragment("data @> {\"current_location\": 64352}")
    select: object.id
  )

  build_active_command_set(caller, context_query)
  '''

  ## List

  Single values are wrapped in a list.

  Examples:
  '''
  object = 42
  build_active_command_set(object, object)
  '''
  '''
  object = 42
  context = [42, 1, 3, 5, 7, 11, 13, 17, 23, 27]
  build_active_command_set(object, context)
  '''

  The active Command list is the result of merging all Command Sets attached to a set of Objects in a determanistic
  order.

  All Command Sets within the context are retrieved and then sorted from oldest to newest, then grouped by priority,then
  further grouped within each priority group by type of merge to be performed, These merge type groups are then
  prioritized by their types before the whole thing is reduced down to a final Command Set. Oldest is defined as the
  order in which the Command Sets were added to the Object. If there is a tie between two or more Command Sets, they
  will be sorted alphabetically.
  """
  @spec build_active_command_set(object_id, query | object_id | [object_id]) :: [] | __MODULE__.t()
  def build_active_command_set(caller, context) when is_integer(context) do
    build_active_command_set(caller, List.wrap(context))
  end

  def build_active_command_set(caller, context) when is_list(context) do
    query =
      from(
        object in Object,
        join: command_set in assoc(object, :command_sets),
        on: object.id == command_set.object_id,
        select: {command_set.object_id, command_set.callback_module, command_set.config},
        where:
          object.id in ^context and
            command_set.visibility != ^command_set_visibility_internal() and
            object.id != ^caller,
        or_where:
          object.id in ^context and
            command_set.visibility != ^command_set_visibility_external() and
            object.id == ^caller,
        order_by: [asc: command_set.inserted_at, asc: command_set.callback_module]
      )

    do_build(query)
  end

  def build_active_command_set(caller, context_query) do
    query =
      from(
        object in Object,
        join: obj in subquery(context_query),
        on: object.id == obj.id,
        join: command_set in assoc(object, :command_sets),
        on: object.id == command_set.object_id,
        select: {command_set.object_id, command_set.callback_module, command_set.config},
        where:
          command_set.visibility != ^command_set_visibility_internal() and object.id != ^caller,
        or_where:
          command_set.visibility != ^command_set_visibility_external() and object.id == ^caller,
        order_by: [asc: command_set.inserted_at, asc: command_set.callback_module]
      )

    do_build(query)
  end

  @spec do_build(term) :: [] | [command]
  defp do_build(context_query) do
    case Repo.all(context_query) do
      [] ->
        []

      command_sets ->
        command_sets
        # Transform each command set from database into a command set struct
        |> Enum.reduce([], fn {object_id, callback_module, config}, list ->
          [build_command_set(object_id, String.to_existing_atom(callback_module), config) | list]
        end)
        |> Enum.reverse()
        |> Enum.sort(fn first_command_set, second_command_set ->
          if first_command_set.priority == second_command_set.priority do
            sort_by_merge_type(first_command_set, second_command_set)
          else
            first_command_set.priority <= second_command_set.priority
          end
        end)
        |> Enum.reduce(nil, fn higher_priority_command_set, lower_priority_command_set ->
          merge(
            higher_priority_command_set,
            lower_priority_command_set
          )
        end)
        |> (& &1.keys).()
        |> Enum.filter(fn command -> locks_pass?(command) end)
    end
  end

  defp locks_pass?(command) do
    Enum.all?(command.locks, fn
      {lock, config} ->
        lock.check(:command, command.object_id, config)

      lock ->
        lock.check(:command, command.object_id, nil)
    end)
  end

  @doc """
  Merge two Command Sets according to their priority and merge type rules.
  """
  @spec merge(%__MODULE__{}, %__MODULE__{} | nil) :: %__MODULE__{}
  def merge(command_set_a, command_set_b)

  def merge(command_set_a, nil) do
    command_set_a
  end

  def merge(command_set_a, command_set_b) do
    sort_function = &sort(&1.priority, &2.priority)

    [higher_priority_command_set, lower_priority_command_set] =
      Enum.sort([command_set_a, command_set_b], sort_function)

    merge_type =
      if Map.has_key?(higher_priority_command_set.overrides, lower_priority_command_set.name) do
        higher_priority_command_set.overrides[lower_priority_command_set.name]
      else
        higher_priority_command_set.merge_type
      end

    allow_duplicates = higher_priority_command_set.allow_duplicates

    merged_keys =
      merge_keys(
        merge_type,
        higher_priority_command_set.keys,
        lower_priority_command_set.keys,
        allow_duplicates
      )

    %{command_set_a | keys: merged_keys}
  end

  @doc """
  Sort function for merge sets.

  Order, from first-to-last, is union, intersect, replace, and remove
  """
  @spec sort_by_merge_type(%__MODULE__{}, %__MODULE__{}) :: boolean
  defp sort_by_merge_type(command_set_1, command_set_2) do
    case {command_set_1, command_set_2} do
      {%{merge_type: :union}, _} -> true
      {%{merge_type: :intersect}, %{merge_type: :union}} -> false
      {%{merge_type: :intersect}, _} -> true
      {%{merge_type: :replace}, %{merge_type: :remove}} -> false
      {%{merge_type: :replace}, _} -> true
      {%{merge_type: :remove}, %{merge_type: :remove}} -> true
      {%{merge_type: :remove}, _} -> false
    end
  end

  @spec sort(priority | nil, priority | nil) :: boolean
  defp sort(nil, nil), do: true
  defp sort(nil, _priority_b), do: false
  defp sort(_priority_a, nil), do: true
  defp sort(priority_a, priority_b), do: priority_a >= priority_b

  @spec merge_keys(
          merge_type,
          %__MODULE__{},
          %__MODULE__{},
          allow_duplicates :: boolean
        ) ::
          [term]
  defp merge_keys(:union, higher_priority_keys, lower_priority_keys, true) do
    higher_priority_keys ++ lower_priority_keys
  end

  defp merge_keys(:union, higher_priority_keys, lower_priority_keys, false) do
    lower_priority_keys =
      Enum.drop_while(lower_priority_keys, fn low_priority_key ->
        Enum.any?(higher_priority_keys, &comparison_function.(&1, low_priority_key))
      end)

    higher_priority_keys ++ lower_priority_keys
  end

  defp merge_keys(:intersect, higher_priority_keys, lower_priority_keys, _) do
    Enum.filter(higher_priority_keys, fn high_priority_key ->
      Enum.any?(lower_priority_keys, fn low_priority_key ->
        comparison_function.(high_priority_key, low_priority_key)
      end)
    end)
  end

  defp merge_keys(:remove, higher_priority_keys, lower_priority_keys, _) do
    Enum.filter(lower_priority_keys, fn low_priority_key ->
      !Enum.any?(higher_priority_keys, fn high_priority_key ->
        comparison_function.(high_priority_key, low_priority_key)
      end)
    end)
  end

  defp merge_keys(:replace, higher_priority_keys, _lower_priority_keys, _) do
    higher_priority_keys
  end

  # Used within Command Set when merging. In the case of a Command Set, the keys are callback modules which implement
  # the Exmud.Engine.Command behaviour. When comparing Commands, both the key and the aliases need to be checked for
  # conflict.
  @spec comparison_function(%Command{}, %Command{}) :: boolean
  defp comparison_function(command_a, command_b) do
    key_and_aliases_a = [command_a.key | command_a.aliases]
    key_and_aliases_b = [command_b.key | command_b.aliases]
    Enum.any?(key_and_aliases_a, &(&1 in key_and_aliases_b))
  end

  # Building a merge set means transforming the retrieved callback module/config into a Command struct.
  @spec build_command_set(object_id, callback_module, config) :: term
  defp build_command_set(object_id, callback_module, config) do
    keys =
      config
      |> callback_module.commands()
      |> Enum.map(fn command ->
        %Command{
          object_id: object_id,
          callback_module: command,
          config: config
        }
      end)

    %__MODULE__{
      allow_duplicates: callback_module.allow_duplicates(config),
      keys: keys,
      name: callback_module.name(config),
      overrides: callback_module.merge_overrides(config),
      priority: callback_module.merge_priority(config),
      merge_type: callback_module.merge_type(config)
    }
  end

  @spec command_set_query(object_id, [callback_module]) :: term
  defp command_set_query(object_id, command_set_callback_modules) do
    command_set_callback_modules = command_set_callback_modules |> Enum.map(&Atom.to_string/1)

    from(
      command_set in CommandSet,
      where:
        command_set.callback_module in ^command_set_callback_modules and
          command_set.object_id == ^object_id
    )
  end
end
