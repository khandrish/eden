defmodule Exmud.Player do
  @moduledoc """
  This module is the interface for managing the communication for and lifecycle
  of players. In this context a player is a representation of an external actor
  within the system. What that means in practice is up to the application using
  Exmud to decide.
  """

  alias Exmud.Component
  alias Exmud.Component.Player
  alias Exmud.Db
#  alias Exmud.PlayerSup
  alias Exmud.Registry
  require Logger
  use GenServer


  #
  # API
  #


  # player management

  def add(names) when is_list(names) do
    names
    |> Enum.each(fn(name) ->
      Db.create()
      |> Component.add(Player, %{name: name})
    end)

    names
  end

  def add(name) do
    add([name])
    |> hd()
  end

  def exists?(names) when is_list(names) do
    Db.transaction(fn ->
      names
      |> Enum.map(fn(name) ->
        {name, Player.find(name) != []}
      end)
    end)
  end

  def exists?(name) do
    exists?([name])
    |> hd()
    |> elem(1)
  end

  def remove(names) when is_list(names) do
    Db.transaction(fn ->
      names
      |> Enum.each(fn(name) ->
        find(name)
        |> Db.delete()
      end)
    end)

    names
  end

  def remove(name) do
    remove([name])
    |> hd()
  end

  # player data management

  def delete_key(player, key) do
    Db.transaction(fn ->
      find(player)
      |> Db.delete(Player, key)
    end)

    player
  end

  def get_key(player, key) do
    Db.transaction(fn ->
      find(player)
      |> hd()
      |> Db.read(Player, key)
    end)
  end

  def has_key?(player, key) do
    Db.transaction(fn ->
      find(player)
      |> hd()
      |> Db.has_all(Player, key)
    end)
  end

  def put_key(player, key, value) do
    Db.transaction(fn ->
      find(player)
      |> Db.write(Player, key, value)
    end)

    player
  end

  # player session management

  def has_active_session?(player) do
    Registry.name_registered?(player)
  end

  def start_session(players, args \\ %{})
  def start_session(players, args) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      {:ok, _pid} = Supervisor.start_child(Exmud.PlayerSup, [player, args])
      player
    end)
  end

  def start_session(player, args), do: hd(start_session([player], args))

  def session_state(players) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      state = Registry.whereis_name(player)
      |> GenServer.call(:state)
      {player, state}
    end)
  end

  def session_state(player) do
    session_state([player])
    |> hd()
    |> elem(1)
  end

  def stop_session(players, args \\ %{})
  def stop_session(players, args) when is_list(players) do
    players
    |> Enum.each(fn(player) ->
      case Registry.whereis_name(player) do
        nil -> :ok
        process -> GenServer.call(process, {:stop, args})
      end
    end)

    players
  end

  def stop_session(player, args), do: hd(stop_session([player], args))

  # manage player puppets and access information about them

  def has_puppet? do

  end

  def puppet do

  end

  def unpuppet do

  end

  def which_puppets do

  end

  # worker callback

  @doc false
  def start_link(player, args) do
    GenServer.start_link(__MODULE__, {player, args})
  end


  #
  # GenServer Callbacks
  #


  def init({name, _args}) do
    Registry.register_name(name)
    {:ok, %{name: name}}
  end

  def handle_call({:stop, _args}, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def terminate(_reason, %{name: name} = _state) do
    Registry.unregister_name(name)
    :ok
  end

  #
  # Private Functions
  #

  defp find(name) do
    Db.find_with_all(Player, :name, &(&1 == name))
  end
end
