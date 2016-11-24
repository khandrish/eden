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
  alias Exmud.PlayerSessionSup
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
      Db.create() # Mnesia client can create ids outside transaction, may break if client changes.
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
  
  def send_output(players, output) when is_list(players) do
    players
    |> Enum.each(fn(player) ->
      Registry.whereis_name(player)
      |> GenServer.call({:send_output, output})
    end)
    players
  end
  
  def send_output(player, output) do
    send_output([player], output)
    |> hd()
  end

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

  def start_session(players, args \\ %{})
  def start_session(players, args) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      if exists?(player) === true do
        {:ok, _pid} = Supervisor.start_child(PlayerSessionSup, [player, args])
        player
      else
        {:error, :no_such_player}
      end
    end)
  end

  def start_session(player, args), do: hd(start_session([player], args))

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
  
  def stream_session_output(players, handler_fun) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      case Registry.whereis_name(player) do
        nil -> {player, {:error, :no_such_player}}
        process ->
          :ok = GenServer.call(process, {:stream_output, handler_fun})
          player
      end
    end)
  end
  
  def stream_session_output(player, handler_fun) do
    case hd(stream_session_output([player], handler_fun)) do
      {player, error} -> error
      player -> player
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


  defp find(name) do
    Db.find_with_all(Player, :name, &(&1 == name))
  end
end
