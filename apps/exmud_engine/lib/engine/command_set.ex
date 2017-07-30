defmodule Exmud.Engine.CommandSet do
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.CommandSet
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # API
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
          Logger.warn("Attempt to add command set onto non existing object `#{object_id}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end

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


  #
  # Private functions
  #


  defp command_set_query(object_id, command_sets) do
    from command_set in CommandSet,
      where: command_set.command_set in ^Enum.map(command_sets, &serialize/1)
        and command_set.object_id == ^object_id
  end
end