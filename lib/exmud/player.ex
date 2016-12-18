defmodule Exmud.Player do
  @moduledoc """
  This module is the interface for managing the communication for and lifecycle
  of players. In this context a player is a representation of an external actor
  within the system. What that means in practice is up to the application using
  Exmud to decide.
  """

  alias Exmud.Attribute
  alias Exmud.GameObject
  alias Exmud.PlayerSessionSup
  alias Exmud.Registry
  alias Exmud.Tag
  require Logger
  use GenServer
  
  @alias_category "__ALIAS__"
  @player_category "player"
  @player_tag "__PLAYER__"
  @tag_category "__SYSTEM_TAG__"


  #
  # API
  #


  # player management

  def add(key) do
    case exists?(key) do
      true -> {:error, :player_already_exists}
      false ->
        with {:ok, oid} <- GameObject.new(key),
             :ok <- Tag.add(oid, @player_tag, @tag_category),
             :ok <- Tag.add(oid, key, @alias_category),
             # TODO: Add command sets for a player
          do: :ok
    end
  end

  def exists?(key) do
    find(key) != nil
  end

  def remove(key) do
    case find(key) do
      nil -> {:error, :no_such_player}
      oid -> GameObject.delete(oid)
    end
  end

  # player data management
  
  def add_attribute(key, name, data) do
    passthrough(&Attribute.add/3, [find(key), name, data])
  end

  def get_attribute(key, name) do
    passthrough(&Attribute.get/2, [find(key), name])
  end
  
  def has_attribute?(key, name) do
    passthrough(&Attribute.has?/2, [find(key), name])
  end
  
  def remove_attribute(key, name) do
    passthrough(&Attribute.remove/2, [find(key), name])
  end
  
  def update_attribute(key, name, data) do
    passthrough(&Attribute.update/3, [find(key), name, data])
  end

  # player session management

  def has_active_session?(key) do
    Registry.key_registered?(key, @player_category)
  end
  
  def send_output(key, output) do
    case Registry.read_key(key, @player_category) do
      {:ok, pid} ->  GenServer.call(pid, {:send_output, output})
      {:error, :no_such_key} -> {:error, :no_such_player}
    end
  end

  def start_session(key, args \\ %{}) do
    if exists?(key) === true do
      {:ok, _pid} = Supervisor.start_child(PlayerSessionSup, [key, args])
      :ok
    else
      {:error, :no_such_player}
    end
  end

  def stop_session(key, args \\ %{}) do
    case Registry.read_key(key, @player_category) do
      {:error, :no_such_key} -> {:error, :no_session_active}
      {:ok, process} -> GenServer.call(process, {:stop, args})
    end
  end

  def stream_session_output(key, handler_fun) do
    case Registry.read_key(key, @player_category) do
      {:error, :no_such_key} -> {:error, :no_such_player}
      {:ok, process} -> GenServer.call(process, {:stream_output, handler_fun})
    end
  end

  # manage player puppets and access information about them

  def has_puppet? do

  end

  def puppet do

  end

  def unpuppet do

  end

  def which_puppets do

  end


  #
  # Private Functions
  #
  

  defp find(key) do
    case GameObject.list(objects: [key], tags: [{@player_tag, @tag_category}]) do
      [] -> nil
      objects -> hd(objects)
    end
  end
  
  defp passthrough(_, [nil|_]), do: {:error, :no_such_player}
  defp passthrough(function, args) do
    apply(function, args)
  end
end
