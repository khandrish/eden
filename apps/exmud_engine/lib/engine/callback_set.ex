defmodule Exmud.Engine.CallbackSet do
  @moduledoc """
  Callback Sets not only allow Callbacks to be added to/removed from Objects in bulk, but they define the rules by which
  multiple Callback Sets on an Object can be merged to present a final unified set of Callbacks for further processing.
  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.CallbackSet

      @doc false
      def name, do: Atom.to_string(__MODULE__)

      @doc false
      def callbacks(_config), do: []

      @doc false
      def merge_priority(_config), do: 1

      @doc false
      def merge_type(_config), do: :union

      @doc false
      def merge_keys(config), do: callbacks(config)

      @doc false
      def merge_overrides(_config), do: %{}

      @doc false
      def merge_duplicates(_config), do: false

      @doc false
      def merge_name(_config), do: name()

      @doc false
      def merge_function(_config), do: &(&1.name == &2.name)

      defoverridable callbacks: 1,
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
  The name of the Callback.
  """
  @callback name :: String.t()

  @doc """
  The function used to compare one key to another to determine equality when being merged.
  """
  @callback merge_function(config) :: function

  @doc """
  The merge type to use when being merged, unless an override matches in which case that is used instead.
  Default to ':union'
  """
  @callback merge_type(config) :: merge_type

  @doc """
  The overrides to check against when determining merge_type. If any match the name of a lower priority CallbackSet, the
  specified merge type will be used instead of what is returned by 'merge_type/1'
  """
  @callback merge_overrides(config) :: merge_type

  @doc """
  The keys to be merged.
  """
  @callback merge_keys(config) :: [key]

  @doc """
  The name to use when checking for overrides. Defaults to the name of the CallbackSet as provided by 'name/1'.
  """
  @callback merge_name(config) :: String.t()

  @doc """
  The generated list of callbacks that are contained in the CallbackSet.
  """
  @callback callbacks(config) :: [term]

  @doc """
  The priority of the CallbackSet when being merged. Default is 1.
  """
  @callback merge_priority(config) :: integer

  @typedoc "Configuration passed through to a callback module."
  @type config :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "Id of the Object the CallbackSet is attached to."
  @type object_id :: integer

  @typedoc "The name of the CallbackSet as registered with the Engine."
  @type name :: String.t()

  @typedoc "A Callback to be executed by the Engine."
  @type callback :: term

  @typedoc "A key to be merged."
  @type key :: term

  @typedoc "The callback_module that is the implementation of the CallbackSet logic."
  @type callback_module :: atom

  @typedoc "One of a finite set of types of merges that can take place."
  @type merge_type :: :union | :intersect | :remove | :replace

  @typedoc "The name of the CallbackSet as registered with the Engine."
  @type callback_set_name :: String.t()

  alias Exmud.Engine.Cache
  alias Exmud.Engine.MergeSet
  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.CallbackSet
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger

  #
  # API
  #

  @doc """
  Attach a Callback Set to an Object.
  """
  @spec attach(object_id, callback_set_name, config) ::
          :ok
          | {:error, :no_such_object}
          | {:error, :already_attached}
          | {:error, :no_such_callback_set}
  def attach(object_id, callback_set_name, config \\ nil) do
    with {:ok, _} <- lookup(callback_set_name) do
      record =
        CallbackSet.new(%{object_id: object_id, name: callback_set_name, config: pack_term(config)})

      ObjectUtil.attach(record)
    end
  end

  @doc """
  Build the active list of Callbacks for an Object.

  The active list of Callbacks is the result of merging all Callback Sets attached to an Object in a determanistic order.
  The oldest attached Callback Set is used as the base, with increasingly newer Callback Sets merged on top while still
  respecting priority. If the oldest Callback Set also happens to have the highest priority, it will be merged last.
  """
  @spec build_active_callback_list(object_id) :: [] | [callback]
  def build_active_callback_list(object_id) do
    query =
      from cs in callback_set_query(object_id),
        select: {cs.name, cs.config},
        order_by: [asc: cs.inserted_at]

    case Repo.all(query) do
      [] ->
        []
      callback_sets ->
        callback_sets
        |> Stream.map(fn {name, config} ->
          case lookup(name) do
            {:ok, callback_module} ->
              build_merge_set(callback_module, config)
            _ ->
              Logger.error("Callback Set '#{name}' found attached to Object '#{object_id}' with no corresponding registered Callback Set")
              nil
          end
        end)
        |> Stream.reject(&(&1 == nil))
        |> Enum.sort(&(&1.priority < &2.priority))
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
  Check to see if an Object has all of the provided Callback Sets attached.
  """
  @spec has_all?(object_id, callback_set_name | [callback_set_name]) :: boolean
  def has_all?(object_id, callback_set_names) do
    callback_set_names = List.wrap(callback_set_names)

    query =
      from(callback_set in callback_set_query(object_id, callback_set_names), select: count("*"))

    Repo.one(query) == length(callback_set_names)
  end

  @doc """
  Check to see if an Object has any of the provided Callback Sets attached.
  """
  @spec has_any?(object_id, callback_set_name | [callback_set_name]) :: boolean
  def has_any?(object_id, callback_set_names) do
    callback_set_names = List.wrap(callback_set_names)

    query =
      from(callback_set in callback_set_query(object_id, callback_set_names), select: count("*"))

    Repo.one(query) > 0
  end

  @doc """
  Detach one or more Callback Sets from an Object atomically. If one cannot be detached, none will be.
  """
  @spec detach(object_id, callback_set_name | [callback_set_name]) :: :ok | :error
  def detach(object_id, callback_set_names) do
    callback_set_names = List.wrap(callback_set_names)

    Repo.transaction(fn ->
      callback_set_query(object_id, callback_set_names)
      |> Repo.delete_all()
      |> case do
        {number_deleted, _} when number_deleted == length(callback_set_names) -> :ok
        _ -> Repo.rollback(:error)
      end
    end)
    |> elem(1)
  end

  @doc """
  Detach one or more Callback Sets from an Object.

  No attempt will be made to validate how many were actually detached, making this method more useful for
  fire-and-forget type deletes where some or all of the Callback Sets may not actually exist on the Object
  """
  @spec detach!(object_id, callback_set_name | [callback_set_name]) :: :ok
  def detach!(object_id, callback_set_names) do
    callback_set_names = List.wrap(callback_set_names)

    callback_set_query(object_id, callback_set_names)
    |> Repo.delete_all()

    :ok
  end

  @spec callback_set_query(object_id, [callback_set_name]) :: term
  defp callback_set_query(object_id, callback_set_names) do
    from(
      callback_set in CallbackSet,
      where: callback_set.name in ^callback_set_names and callback_set.object_id == ^object_id
    )
  end

  @spec callback_set_query(object_id) :: term
  defp callback_set_query(object_id) do
    from(
      callback_set in CallbackSet,
      where: callback_set.object_id == ^object_id
    )
  end

  #
  # Manipulation of Callback Sets in the Engine.
  #

  @cache :callback_set_cache

  @doc """
  List all Callback Sets which are currently registered with the Engine.
  """
  @spec list_registered :: [] | [callback_module]
  def list_registered() do
    Logger.info("Listing all registered Callback Sets")
    Cache.list(@cache)
  end

  @doc """
  Lookup the callback module for the Callback Set with the provided name.
  """
  @spec lookup(name) :: {:ok, callback_module} | {:error, :no_such_callback_set}
  def lookup(name) do
    case Cache.get(@cache, name) do
      {:error, _} ->
        Logger.error("Lookup failed for Callback Set registered with name `#{name}`")
        {:error, :no_such_callback_set}

      result ->
        Logger.info("Lookup succeeded for Callback Set registered with name `#{name}`")
        result
    end
  end

  @doc """
  Register a callback module for a Callback Set with the provided name.
  """
  @spec register(callback_module) :: :ok
  def register(callback_module) do
    name = callback_module.name()

    Logger.info(
      "Registering Callback Set with name `#{name}` and module `#{inspect(callback_module)}`"
    )

    Cache.set(@cache, callback_module.name(), callback_module)
  end

  @doc """
  Check to see if a Callback Set has been registered with the provided name.
  """
  @spec registered?(callback_module) :: boolean
  def registered?(callback_module) do
    Logger.info("Checking registration of Callback Set with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregisters the callback module for a Callback Set with the provided name.
  """
  @spec unregister(callback_module) :: :ok
  def unregister(callback_module) do
    Logger.info("Unregistering Callback Set with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end
end
