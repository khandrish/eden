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
  alias Exmud.PlayerSup
  alias Exmud.Registry
  require Logger
  use GenServer


  #
  # API
  #


  # player management

  def add(name) do
    Db.create()
    |> Component.add(Player)
  end

  def exists?(name) do
    Component.find_with_value(fn(value) -> value == name end) != []
  end

  def remove(name) do
    # Other then killing active sessions, the scope of this function is limited.
    # References to the player will not be sought out and changed and logic must
    # account for players going missing.
  end

  # player data management

  def delete(entity, key) do
    Db.transaction(fn ->
      Db.delete(entity, Player, key)
    end)
  end

  def get(entity, key) do
    Db.transaction(fn ->
      Db.read(entity, Player, key)
    end)
  end

  def has?(entity, key) do
    Db.transaction(fn ->
      Db.has_all?(entity, Player, key)
    end)
  end

  def put(entity, key, value) do
    Db.transaction(fn ->
      Db.write(entity, Player, key, value)
    end)
  end

  # player session management

  def get_session_history do

  end

  def get_session_info do

  end

  def has_active_session?(player) do
    Registry.name_registered?(player)
  end

  def start_session(player) do
    player
  end

  def start_session(players, args \\ %{})
  def start_session(players, args) when is_list(players) do
    players
    |> Enum.each(fn(player) ->
      {:ok, _} = Supervisor.start_child(Exmud.PlayerSup, [player, args])
    end)

    players
  end

  def start_session(player, args), do: hd(start([player], args))

  def start_link(player, args) do
    GenServer.start_link(__MODULE__, {player, args})
  end

  def state(players) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      state = Registry.whereis_name(player)
      |> GenServer.call(:state)
      {player, state}
    end)
  end

  def state(player) do
    state([player])
    |> hd()
    |> elem(1)
  end

  def stop_session(players, args \\ %{})
  def stop_session(players, args) when is_list(players) do
    players
    |> Enum.each(fn(system) ->
      Registry.whereis_name(system)
      |> GenServer.call({:stop, args})
    end)

    systems
  end

  def stop_session(player, args), do: hd(stop([player], args))

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
  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end


  # def new(name) do
  #   Logger.debug("Creating player with name `#{name}`")
  #   Entity.transaction(fn ->
  #     Entity.new()
  #     |> Entity.add_component(P)
  #     |> Entity.add_key(P, "name", name)
  #   end)

  #   name
  # end

  # def delete(name) do
  #   Logger.debug("Deleting player with name `#{name}`")
  #   end_session(name)
  #   Entity.transaction(fn ->
  #     Entity.
  #     Entity.new()
  #     |> Entity.add_component(P)
  #     |> Entity.add_key(P, "name", name)
  #   end)
  # end

  # def exists?(name) do
  #   Logger.debug("Checking existance of player `#{name}`")
  #   Entity.transaction(fn ->
  #     Entity.value_exists?(P, "name", name)
  #   end)
  # end

  # def end_session(name) do
  #   case Registry.find_by_name(name) do
  #     nil -> :ok
  #     player_session -> GenServer.call(player_session, :end_session)
  #   end
  # end

  # @doc """
  # Once a character is connected they can be listened to by any number of
  # interested parties. This method registers the calling process as being
  # interested in the output stream for that character.

  # The output stream contains output from the engine meant for the player,
  # examples being text output during combat, UI updates, chat messages, and
  # so on.
  # """
  # def listen() do
  #   # Assume character is connected and do the thing
  # end

  # @doc """
  # A connected player can puppet entities via this method.
  # """
  # def puppet(player, puppet) do

  # end

  # def session_exists?(name) do
  #   Logger.debug("Checking to see if session exists for player `#{name}`")
  #   Registry.name_registered?(name)
  # end

  # def start_session(name) do
  #   Logger.debug("Starting session for player `#{name}`")
  #   if exists?(name) do
  #     Logger.debug("Player `#{name}` exists")
  #     case session_exists?(name) do
  #       true ->
  #         Logger.warn("Session for player `#{name}` already started")
  #         :ok
  #       false ->
  #         Logger.info("Starting session for player `#{name}`")
  #         PlayerSup.start_player(name)
  #         :ok
  #     end
  #   else
  #     Logger.warn("Player `#{name}` does not exist")
  #     {:error, :no_such_player}
  #   end

  # end


  #
  # GenServer Callbacks
  #


  def init(name) do
    Logger.debug("Player session starting with name `#{name}`")
    :ok = Registry.register_name(name)
    {:ok, %{name: name}}
  end

  # def handle_call(:end_session, _from, state) do
  #   {:stop, :normal, :ok, state}
  # end

  def terminate(_reason, %{name: name} = state) do
    Registry.unregister_name(name)
    :ok
  end

  #
  # Private Functions
  #
end
