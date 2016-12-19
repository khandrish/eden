defmodule Exmud.CommandSet do
  @moduledoc """
  An `Exmud.GameObject` can have an arbitrary number of command sets associated
  with it.
  
  These command sets provide the building blocks for determining which commands
  a player, or anything controlling/issuing commands for an object, has access
  to.
  
  A command set, in this context, is a module which implements the
  `Exmud.CommandSet` behavior and which is registered with the engine. When a
  command is being processed, the command sets from the current context (more
  on this later) are gathered and then merged to determine the final set of
  commands that are available. Only then is the command checked against these
  available commands and then executed, or not, as logic dictates.
  """
  
  alias Exmud.GameObject
  alias Exmud.Registry
  alias Exmud.Repo
  alias Exmud.Schema.CommandSet
  import Ecto.Query
  import Exmud.Utils
  require Logger
  
  @command_set_category "command_set"
  
  
  #
  # API
  #
  
  
  # Management of command sets within the engine
  
  @doc """
  In order for the engine to map command sets to callback modules, each
  callback module must be registered with the engine via a unique key.
  """
  def register(key, callback_module) do
    Logger.debug("Registering command set for key `#{key}` with module `#{callback_module}`")
    Registry.register_key(key, @command_set_category, callback_module)
  end
  
  def registered?(key) do
    Registry.key_registered?(key, @command_set_category)
  end
  
  def which_module(key) do
    Logger.debug("Finding callback module for command set with key `#{key}`")
    case Registry.read_key(key, @command_set_category) do
      {:error, _} ->
        Logger.warn("Attempt to find callback module for command set with key `#{key}` failed")
        {:error, :no_such_command_set}
      result -> result
    end
  end
  
  def unregister(key) do
    Registry.unregister_key(key, @command_set_category)
  end
  
  # Manipulation of command sets on an object
  
  def add(oid, key) do
    args = %{key: key, oid: oid}
    Repo.insert(CommandSet.changeset(%CommandSet{}, args))
    |> normalize_noreturn_result()
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :oid) do
          Logger.warn("Attempt to add command set onto non existing object `#{oid}` failed")
          {:error, :no_such_game_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end
  
  def has?(oid, key) do
    case Repo.one(command_set_query(oid, key)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end
  
  def list(keys) do
    GameObject.list(command_sets: List.wrap(keys))
  end
  
  def delete(oid, key) do
    Repo.delete_all(command_set_query(oid, key))
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_command_set}
      _ -> {:error, :unknown}
    end
  end
  
  
  #
  # Private functions
  #
  
  
  defp command_set_query(oid, key) do
    from command_set in CommandSet,
      where: command_set.key == ^key,
      where: command_set.oid == ^oid
  end
end