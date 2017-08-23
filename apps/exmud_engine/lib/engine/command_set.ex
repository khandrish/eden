defmodule Exmud.Engine.CommandSet do
  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.CommandSet
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # Add command set to an object
  #


  def add(object_id, command_set) do
    args = %{command_set: serialize(command_set), object_id: object_id}

    %CommandSet{}
    |> CommandSet.add(args)
    |> Repo.insert()
    |> normalize_repo_result(object_id)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :object_id) do
          Logger.error("Attempt to add Command Set onto non existing object `#{object_id}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end


  #
  # Check presence of command sets on an Object.
  #


  def has(object_id, command_sets) do
    command_sets = List.wrap(command_sets)

    query =
      from command_set in command_set_query(object_id, command_sets),
        select: count("*")

    case Repo.one(query) == length(command_sets) do
      true -> {:ok, true}
      false -> {:ok, false}
    end
  end

  def has_any(object_id, command_sets) do
    command_sets = List.wrap(command_sets)

    query =
      from command_set in command_set_query(object_id, command_sets),
        select: count("*")

    case Repo.one(query) > 0 do
      true -> {:ok, true}
      false -> {:ok, false}
    end
  end


  #
  # Remove command sets from an Object.
  #


  def remove(object_id, command_sets) do
    command_sets = List.wrap(command_sets)

    command_set_query(object_id, command_sets)
    |> Repo.delete_all()
    |> case do
      {0, _} -> {:error, :no_such_command_set}
      {number_deleted, _} when is_integer(number_deleted) -> {:ok, true}
      _ -> {:error, :unknown}
    end
  end

  defp command_set_query(object_id, command_sets) do
    from command_set in CommandSet,
      where: command_set.command_set in ^Enum.map(command_sets, &serialize/1)
        and command_set.object_id == ^object_id
  end


  #
  # Manipulation of Command Sets in the Engine.
  #


  @cache :command_set_cache

  def list_registered() do
    Logger.info("Listing all registered Command Sets")
    Cache.list(@cache)
  end

  def lookup(key) do
    case Cache.get(@cache, key) do
      {:error, _} ->
        Logger.error("Lookup failed for Command Set registered with key `#{key}`")
        {:error, :no_such_command_set}
      result ->
        Logger.info("Lookup succeeded for Command Set registered with key `#{key}`")
        result
    end
  end

  def register(key, callback_module) do
    Logger.info("Registering Command Set with key `#{key}` and module `#{inspect(callback_module)}`")
    Cache.set(@cache, key, callback_module)
  end

  def registered?(key) do
    Logger.info("Checking registration of Command Set with key `#{key}`")
    Cache.exists?(@cache, key)
  end

  def unregister(key) do
    Logger.info("Unregistering Command Set with key `#{key}`")
    Cache.delete(@cache, key)
  end
end