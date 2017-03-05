defmodule Exmud.Player do
  @moduledoc """
  This module is the interface for managing the communication for and lifecycle
  of players. In this context a player is a representation of an external actor
  within the system. What that means in practice is up to the application using
  Exmud to decide.
  """

  alias Ecto.Multi
  alias Exmud.Attribute
  alias Exmud.GameObject
  alias Exmud.PlayerSession
  alias Exmud.PlayerSessionSup
  alias Exmud.Repo
  alias Exmud.Tag
  import Exmud.Utils
  require Logger
  use GenServer

  @alias_category "__ALIAS__"
  @player_category "player"
  @player_tag "__PLAYER__"
  @tag_category "__SYSTEM_TAG__"


  #
  # API
  #


  @doc """
  Add a player to the system with the unique `key`.

  Returns `{:ok, object_id}`.

  ## Examples

      iex> Exmud.Player.new(:john)
      :ok

  """
  def add(key) do
    Multi.new()
    |> existence_check(key)
    |> GameObject.new("new", key)
    |> Multi.run("add tag", fn(%{"new" => oid}) ->
      GameObject.add_tag(oid, @player_tag, @tag_category)
    end)
    |> Repo.transaction()
    |> normalize_multi_result("new")
  end

  def add(multi, multi_key \\ "add", key) do
    Multi.run(multi, multi_key, fn(_) ->
      add(key)
    end)
  end

  def exists(key) do
    case which(key) do
      {:ok, _} -> {:ok, true}
      {:error, _} -> {:ok, false}
    end
  end

  def exists(multi, multi_key \\ "exists", key) do
    Multi.run(multi, multi_key, fn(_) ->
      exists(key)
    end)
  end

  def remove(key) do
    Multi.new()
    |> which(key)
    |> Multi.run("delete", fn(%{"which" => oid}) ->
      GameObject.delete(oid)
    end)
    |> Repo.transaction()
    |> normalize_multi_result("which")
  end

  def remove(multi, multi_key \\ "remove", key) do
    Multi.run(multi, multi_key, fn(_) ->
      remove(key)
    end)
  end

  def which(key) do
    case GameObject.list(objects: [key], tags: [{@player_tag, @tag_category}]) do
      {:ok, []} -> {:error, :no_such_player}
      {:ok, oids} -> {:ok, hd(oids)}
    end
  end

  def which(multi, multi_key \\ "which", key) do
    Multi.run(multi, multi_key, fn(_) ->
      which(key)
    end)
  end


  #
  # Private Functions
  #


  defp existence_check(multi, key) do
    Multi.run(multi, "existence check", fn(_) ->
      case exists(key) do
        {:ok, true} -> {:error, :player_already_exists}
        _ -> {:ok, key}
      end
    end)
  end
end
