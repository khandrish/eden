defmodule Exmud.Engine.CommandSet do
  alias Ecto.Multi
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.CommandSet
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # API
  #


  def add(object_id, callback_module) do
    args = %{callback_module: serialize(callback_module), object_id: object_id}

    %CommandSet{}
    |> CommandSet.add(args)
    |> Repo.insert()
    |> normalize_repo_result(object_id)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :object_id) do
          Logger.warn("Attempt to add command set onto non existing object `#{object_id}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end

  def add(%Ecto.Multi{} = multi, multi_key, object_id, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      add(object_id, callback_module)
    end)
  end

  def has(object_id, callback_modules) do
    callback_modules = List.wrap(callback_modules)

    query =
      from command_set in command_set_query(object_id, callback_modules),
        select: count("*")

    case Repo.one(query) == length(callback_modules) do
      true -> {:ok, true}
      false -> {:ok, false}
    end
  end

  def has(%Ecto.Multi{} = multi, multi_key, object_id, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      has(object_id, callback_module)
    end)
  end

  def has_any(object_id, callback_modules) do
    callback_modules = List.wrap(callback_modules)

    query =
      from command_set in command_set_query(object_id, callback_modules),
        select: count("*")

    case Repo.one(query) == length(callback_modules) do
      true -> {:ok, true}
      false -> {:ok, false}
    end
  end

  def has_any(%Ecto.Multi{} = multi, multi_key, object_id, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      has_any(object_id, callback_module)
    end)
  end

  def remove(object_id, callback_modules) do
    callback_modules = List.wrap(callback_modules)

    command_set_query(object_id, callback_modules)
    |> Repo.delete_all()
    |> case do
      {0, _} -> {:error, :no_such_command_set}
      {number_deleted, _} when is_integer(number_deleted) -> {:ok, true}
      _ -> {:error, :unknown}
    end
  end

  def remove(%Ecto.Multi{} = multi, multi_key, object_id, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      remove(object_id, callback_module)
    end)
  end


  #
  # Private functions
  #


  defp command_set_query(object_id, callback_modules) do
    from command_set in CommandSet,
      where: command_set.callback_module in ^Enum.map(callback_modules, &serialize/1)
        and command_set.object_id == ^object_id
  end
end