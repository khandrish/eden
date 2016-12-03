defmodule Exmud.Player do
  @moduledoc """
  This module is the interface for managing the communication for and lifecycle
  of players. In this context a player is a representation of an external actor
  within the system. What that means in practice is up to the application using
  Exmud to decide.
  """

  alias Exmud.GameObject
  alias Exmud.PlayerSessionSup
  alias Exmud.Registry
  alias Exmud.Repo
  alias Exmud.Schema.GameObject, as: GO
  alias Exmud.Schema.Player, as: P
  alias Exmud.Schema.PlayerData, as: PD
  import Ecto.Query
  require Logger
  use GenServer
  
  @player_tag "__PLAYER__"


  #
  # API
  #


  # player management

  def add(key) do
    case exists?(key) do
      true -> {:error, :player_already_exists}
      false ->
        with {:ok, oid} <- GameObject.new(key),
             :ok <- GameObject.add_tag(oid, @player_tag),
             :ok <- GameObject.add_alias(oid, key),
          do: :ok
    end
  end

  def exists?(key) do
    find(key) != nil
  end

  def remove(key) do
    case find(key) do
      nil -> :ok
      oid -> GameObject.delete(oid)
    end
  end

  # player data management

  def get_attribute(key, name) do
    f = &GameObject.get_attribute/2
    passthrough(f, [find(key), name])
  end
  
  def has_attribute?(key, name) do
    f = &GameObject.has_attribute?/2
    passthrough(f, [find(key), name])
  end
  
  def add_attribute(key, name, data) do
    f = &GameObject.add_attribute/3
    passthrough(f, [find(key), name, data])
  end
  
  def remove_attribute(key, name) do
    f = &GameObject.remove_attribute/2
    passthrough(f, [find(key), name])
  end

  # player session management

  def has_active_session?(key) do
    Registry.name_registered?(key)
  end
  
  def send_output(key, output) do
    Registry.whereis_name(key)
    |> GenServer.call({:send_output, output})
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
    case Registry.whereis_name(key) do
      nil -> {:error, :no_session_active}
      process -> GenServer.call(process, {:stop, args})
    end
  end

  def stream_session_output(key, handler_fun) do
    case Registry.whereis_name(key) do
      nil -> {key, {:error, :no_such_player}}
      process -> GenServer.call(process, {:stream_output, handler_fun})
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
    case GameObject.list(keys: key, tags: @player_tag) do
      [] -> nil
      objects -> hd(objects).id
    end
  end
  
  defp passthrough(_, [nil|_]), do: {:error, :no_such_player}
  defp passthrough(function, args) do
     apply(function, args)
  end
end
