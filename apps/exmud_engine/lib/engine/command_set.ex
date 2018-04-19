defmodule Exmud.Engine.CommandSet do
  @moduledoc """
  Command Sets not only allow Commands to be added to/removed from Objects in bulk, but they define the rules by which
  multiple Command Sets on an Object can be merged to present a final unified set of Commands for further processing.
  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      alias Exmud.Engine.MergeSet
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

      defoverridable merge_priority: 1,
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
  The function used to compare one key to another to determine equality.
  """
  @callback merge_function(key, key) :: boolean

  @typedoc "Configuration passed through to a callback module."
  @type config :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "Id of the Object the Command Set is attached to."
  @type object_id :: integer

  @typedoc "The name of the Command Set as registered with the Engine."
  @type name :: String.t()

  @typedoc "A key to be merged."
  @type key :: term

  @typedoc "The callback_module that is the implementation of the Command Set logic."
  @type callback_module :: atom

  @typedoc "The name of the Command Set as registered with the Engine."
  @type command_set_name :: String.t()

  alias Exmud.Engine.Cache
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
